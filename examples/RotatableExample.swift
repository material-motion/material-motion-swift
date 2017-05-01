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

class Rotatable2: Gesturable {

  @discardableResult
  class func apply(to view: UIView,
                   relativeTo: UIView,
                   withGestureRecognizer existingGesture: UIRotationGestureRecognizer? = nil,
                   constraints applyConstraints: ConstraintApplicator<CGFloat>? = nil) -> Reactive<UIRotationGestureRecognizer> {
    let gesture = prepareGesture(relativeTo: relativeTo, withGestureRecognizer: existingGesture)

    let rotation = Reactive(view.layer).rotation
    var stream = Reactive(gesture).didAnything.rotated(from: rotation)
    if let applyConstraints = applyConstraints {
      stream = applyConstraints(stream)
    }
    stream.subscribeToValue {
      rotation.value = $0
    }

    return Reactive(gesture)
  }
}

class RotatableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleSquareView(), within: view)
    view.addSubview(square)

    Rotatable2.apply(to: square, relativeTo: view)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Use two fingers to rotate the view.")
  }
}
