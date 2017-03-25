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

import Foundation
import UIKit

/**
 Allows a view to be dragged by a gesture recognizer.

 Can be initialized with any of the GesturableConfiguration options.

 **Affected properties**

 - `view.layer.position`

 **Constraints**

 CGPoint constraints may be applied to this interaction. Common constraints include:

 - `{ $0.xLocked(to: somePosition) }`
 - `{ $0.yLocked(to: somePosition) }`
 */
public final class Draggable: Gesturable<UIPanGestureRecognizer>, Interaction, Stateful {
  /**
   A sub-interaction for writing the next gesture recognizer's final velocity to a property.

   Most commonly used to add final velocity to a spring's initial velocity.
   */
  public var finalVelocity: DraggableFinalVelocity {
    return DraggableFinalVelocity(gestureRecognizer: nextGestureRecognizer)
  }

  public func add(to view: UIView,
                  withRuntime runtime: MotionRuntime,
                  constraints applyConstraints: ConstraintApplicator<CGPoint>? = nil) {
    let reactiveView = runtime.get(view)
    let gestureRecognizer = dequeueGestureRecognizer(withReactiveView: reactiveView)
    let position = reactiveView.reactiveLayer.position

    let reactiveGesture = runtime.get(gestureRecognizer)
    aggregateState.observe(state: reactiveGesture.state, withRuntime: runtime)

    var stream = reactiveGesture.translation(addedTo: position)
    if let applyConstraints = applyConstraints {
      stream = applyConstraints(stream)
    }
    runtime.connect(stream, to: position)
  }
}

/**
 A sub-interaction of Draggable for extracting the final velocity and writing it to a property.

 Not directly instantiable. Use Draggable's `finalVelocity` property instead.

 **Constraints**

 CGPoint constraints may be applied to this interaction.
 */
public final class DraggableFinalVelocity: Interaction {
  fileprivate init(gestureRecognizer: UIPanGestureRecognizer) {
    self.gestureRecognizer = gestureRecognizer
  }

  public func add(to target: ReactiveProperty<CGPoint>,
                  withRuntime runtime: MotionRuntime,
                  constraints applyConstraints: ConstraintApplicator<CGPoint>? = nil) {
    let gesture = runtime.get(gestureRecognizer)
    runtime.connect(gesture.velocityOnReleaseStream(in: runtime.containerView),
                    to: target)
  }

  let gestureRecognizer: UIPanGestureRecognizer
}
