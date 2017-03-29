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
public final class Tossable: Interaction, Stateful {

  /**
   The interaction governing drag behaviors.
   */
  public let draggable: Draggable

  /**
   The interaction governing the spring animation.
   */
  public let spring: Spring<CGPoint>

  public init(spring: Spring<CGPoint> = Spring(), draggable: Draggable = Draggable()) {
    self.spring = spring
    self.draggable = draggable
  }

  public func add(to view: UIView,
                  withRuntime runtime: MotionRuntime,
                  constraints: ConstraintApplicator<CGPoint>? = nil) {
    let position = runtime.get(view.layer).position

    // Order matters:
    //
    // 1. When we hand off from the gesture to the spring we want Tossable's state to still be
    //    "active", so we observe the spring's state first and observe draggable's state last; this
    //    ensures that the spring interaction is active before the draggable interaction is at rest.
    // 2. The spring's initial velocity must be set before it's re-enabled.
    // 3. The spring must be registered before draggable in case draggable's gesture is already
    //    active and will want to immediately read the current state of the position property.

    aggregateState.observe(state: spring.state, withRuntime: runtime)

    runtime.add(draggable.finalVelocity, to: spring.initialVelocity)
    runtime.toggle(spring, inReactionTo: draggable)

    runtime.add(spring, to: position, constraints: constraints)
    runtime.add(draggable, to: view, constraints: constraints)

    aggregateState.observe(state: draggable.state, withRuntime: runtime)
  }

  /**
   The current state of the interaction.
   */
  public var state: MotionObservable<MotionState> {
    return aggregateState.asStream()
  }

  let aggregateState = AggregateMotionState()

  @available(*, deprecated, message: "Use init(spring:draggable:) instead.")
  public convenience init(system: @escaping SpringToStream<CGPoint>, draggable: Draggable = Draggable()) {
    self.init(spring: Spring(threshold: 1, system: system), draggable: draggable)
  }
}
