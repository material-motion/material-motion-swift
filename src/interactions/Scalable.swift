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
 Allows a view to be scaled by a gesture recognizer.

 Can be initialized with any of the GesturableConfiguration options.

 **Affected properties**

 - `view.layer.scale`

 **Constraints**

 CGFloat constraints may be applied to this interaction.
 */
public final class Scalable: Gesturable<UIPinchGestureRecognizer>, Interaction, Stateful {
  public func add(to view: UIView,
                  withRuntime runtime: MotionRuntime,
                  constraints applyConstraints: ConstraintApplicator<CGFloat>? = nil) {
    let reactiveView = runtime.get(view)
    let gestureRecognizer = dequeueGestureRecognizer(withReactiveView: reactiveView)
    let scale = reactiveView.reactiveLayer.scale

    let reactiveGesture = runtime.get(gestureRecognizer)
    aggregateState.observe(state: reactiveGesture.state, withRuntime: runtime)

    var stream = reactiveGesture.scaled(from: scale)
    if let applyConstraints = applyConstraints {
      stream = applyConstraints(stream)
    }
    runtime.connect(stream, to: scale)
  }
}
