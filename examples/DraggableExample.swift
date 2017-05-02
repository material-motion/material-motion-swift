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
import IndefiniteObservable
import MaterialMotion

func prepareGesture<GestureType: UIGestureRecognizer>(relativeTo: UIView, withGestureRecognizer existingGesture: GestureType?) -> GestureType {
  let gesture: GestureType
  if let existingGesture = existingGesture {
    gesture = existingGesture
  } else {
    gesture = GestureType()
    relativeTo.addGestureRecognizer(gesture)
  }
  return gesture
}

public class Draggable2 {

  public init(_ view: UIView, containerView: UIView, withGestureRecognizer existingGesture: UIPanGestureRecognizer? = nil) {
    let gesture = prepareGesture(relativeTo: containerView, withGestureRecognizer: existingGesture)
    self.gesture = Reactive(gesture)
    self.property = Reactive(view.layer).position
    self.stream = self.gesture.didAnything.translation(addedTo: property, in: containerView)
  }

  public func start() {
    let property = self.property
    subscription = stream.subscribeToValue {
      property.value = $0
    }
  }

  public func stop() {
    subscription?.unsubscribe()
    subscription = nil
  }

  @discardableResult
  public class func apply(to view: UIView, containerView: UIView, withGestureRecognizer existingGesture: UIPanGestureRecognizer? = nil) -> Draggable2 {
    let draggable = Draggable2(view, containerView: containerView, withGestureRecognizer: existingGesture)
    draggable.start()
    return draggable
  }

  private let stream: MotionObservable<CGPoint>
  private let property: ReactiveProperty<CGPoint>
  private var subscription: Subscription?

  public let gesture: Reactive<UIPanGestureRecognizer>
}

class DraggableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    Draggable2.apply(to: square, containerView: view)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Drag the view to move it.")
  }
}
