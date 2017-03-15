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

/**
 Allows a view to be tossed by a gesture recognizer and animated to a destination using a spring.

 Composed of two sub-interactions: Draggable and Spring.

 The spring interaction will be disabled while the drag interaction is active. The spring
 interaction is enabled once the drag interaction comes to rest.

 **Affected properties**

 - `view.layer.position`

 **Constraints**

 CGPoint constraints may be applied to this interaction. Common constraints include:

 - `{ $0.xLocked(to: somePosition) }`
 - `{ $0.yLocked(to: somePosition) }`
 */
public class Tossable: Interaction, Stateful {

  /**
   The interaction governing drag behaviors.
   */
  public let draggable: Draggable

  /**
   The interaction governing the spring animation.
   */
  public let spring: Spring<CGPoint>

  public init(system: @escaping SpringToStream<CGPoint>, draggable: Draggable = Draggable()) {
    self.spring = Spring(threshold: 1, system: system)
    self.draggable = draggable
  }

  public init(spring: Spring<CGPoint>, draggable: Draggable = Draggable()) {
    self.spring = spring
    self.draggable = draggable
  }

  public func add(to view: UIView,
                  withRuntime runtime: MotionRuntime,
                  constraints: ConstraintApplicator<CGPoint>? = nil) {
    let position = runtime.get(view.layer).position

    let gesture = runtime.get(draggable.nextGestureRecognizer)

    aggregateState.observe(state: spring.state, withRuntime: runtime)
    aggregateState.observe(state: draggable.state, withRuntime: runtime)

    // Order matters:
    //
    // 1. The spring's initial velocity must be set before it's re-enabled.
    // 2. The spring must be registered before draggable in case draggable's gesture is already
    //    active and will want to immediately read the current state of the position property.

    runtime.connect(gesture.velocityOnReleaseStream(in: runtime.containerView), to: spring.initialVelocity)
    runtime.disable(spring, whenActive: gesture)
    runtime.add(spring, to: position, constraints: constraints)

    runtime.add(draggable, to: view, constraints: constraints)
  }

  /**
   The current state of the interaction.
   */
  public var state: MotionObservable<MotionState> {
    return aggregateState.asStream()
  }

  let aggregateState = AggregateMotionState()
}
