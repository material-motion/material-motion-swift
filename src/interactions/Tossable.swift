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

public class Tossable {

  public let draggable: Draggable
  public let spring: Spring<CGPoint>

  init(system: @escaping SpringToStream<CGPoint>, draggable: Draggable = Draggable()) {
    self.spring = Spring(threshold: 1, system: system)
    self.draggable = draggable
  }

  init(spring: Spring<CGPoint>, draggable: Draggable = Draggable()) {
    self.spring = spring
    self.draggable = draggable
  }
}

extension Tossable: Interaction {
  public func add(to view: UIView, withRuntime runtime: MotionRuntime, constraints: Void?) {
    let position = runtime.get(view.layer).position

    let gesture = runtime.get(draggable.nextGestureRecognizer)

    // Order matters:
    //
    // 1. The spring's initial velocity must be set before it's re-enabled.
    // 2. The spring must be registered before draggable in case draggable's gesture is already
    //    active and will want to immediately read the current state of the position property.

    runtime.connect(gesture.velocityOnReleaseStream(in: runtime.containerView), to: spring.initialVelocity)
    runtime.enable(spring, whenAtRest: gesture)
    runtime.add(spring, to: position)

    runtime.add(draggable, to: view)
  }
}
