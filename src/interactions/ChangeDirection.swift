/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

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
 Changes the direction of a transition when the provided pan gesture recognizer completes.

 Without any configuration, will set the direction to backward if the absolute velocity exceeds
 minimumThreshold on the y axis.

 **Common configurations**

 *Modal dialogs and sheets*: cancel a dismissal when tossing up using `whenNegative: .forward`.

 **Constraints**

 Either the x or y axis can be selected. The default axis is y.
 */
public final class ChangeDirection: Interaction {
  /**
   The gesture recognizer that will be observed by this interaction.
   */
  public let gesture: UIPanGestureRecognizer

  /**
   The minimum absolute velocity required change the transition's direction.

   If this velocity is not met, the direction will not be changed.
   */
  public let minimumVelocity: CGFloat

  /**
   The transition direction to emit when the velocity is below -minimumVelocity.
   */
  public let whenNegative: TransitionDirection

  /**
   The transition direction to emit when the velocity is above minimumVelocity.
   */
  public let whenPositive: TransitionDirection

  /**
   - parameter minimumVelocity: The minimum absolute velocity required to change the transition's direction.
   */
  public init(withVelocityOf gesture: UIPanGestureRecognizer, minimumVelocity: CGFloat = 100, whenNegative: TransitionDirection = .backward, whenPositive: TransitionDirection = .backward) {
    self.gesture = gesture
    self.minimumVelocity = minimumVelocity
    self.whenNegative = whenNegative
    self.whenPositive = whenPositive
  }

  /**
   The velocity axis to observe.
   */
  public enum Axis {
    /**
     Observes the velocity's x axis.
     */
    case x

    /**
     Observes the velocity's y axis.
     */
    case y
  }

  public func add(to direction: ReactiveProperty<TransitionDirection>, withRuntime runtime: MotionRuntime, constraints axis: Axis?) {
    let axis = axis ?? .y
    let chooseAxis: (MotionObservable<CGPoint>) -> MotionObservable<CGFloat>
    switch axis {
    case .x:
      chooseAxis = { $0.x() }
    case .y:
      chooseAxis = { $0.y() }
    }
    runtime.connect(chooseAxis(runtime.get(gesture).velocityOnReleaseStream())
      .thresholdRange(min: -minimumVelocity, max: minimumVelocity)
      .rewrite([.below: whenNegative, .above: whenPositive]),
                    to: direction)

  }
}
