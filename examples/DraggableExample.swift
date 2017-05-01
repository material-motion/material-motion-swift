/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import MaterialMotion

protocol Gesturable {
  associatedtype GestureType: UIGestureRecognizer
  associatedtype ConstraintType

  @discardableResult
  static func apply(to view: UIView,
                    relativeTo: UIView,
                    withGestureRecognizer existingGesture: GestureType?,
                    constraints applyConstraints: ConstraintType?) -> Reactive<GestureType>
}

extension Gesturable {
  static func prepareGesture(relativeTo: UIView, withGestureRecognizer existingGesture: GestureType?) -> GestureType {
    let gesture: GestureType
    if let existingGesture = existingGesture {
      gesture = existingGesture
    } else {
      gesture = GestureType()
      relativeTo.addGestureRecognizer(gesture)
    }
    return gesture
  }
}

private class Draggable: Gesturable {

  @discardableResult
  class func apply(to view: UIView,
                   relativeTo: UIView,
                   withGestureRecognizer existingGesture: UIPanGestureRecognizer? = nil,
                   constraints applyConstraints: ConstraintApplicator<CGPoint>? = nil) -> Reactive<UIPanGestureRecognizer> {
    let gesture = prepareGesture(relativeTo: relativeTo, withGestureRecognizer: existingGesture)

    let position = Reactive(view.layer).position
    var stream = Reactive(gesture).didAnything.translation(addedTo: position, in: relativeTo)
    if let applyConstraints = applyConstraints {
      stream = applyConstraints(stream)
    }
    stream.subscribeToValue {
      position.value = $0
    }

    return Reactive(gesture)
  }
}

class DraggableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    Draggable.apply(to: square, relativeTo: view)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Drag the view to move it.")
  }
}
