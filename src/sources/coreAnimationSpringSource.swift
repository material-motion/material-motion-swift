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
 Create a core animation spring system for a Spring plan.

 Only works with Subtractable types due to use of additive animations.
 */
@available(iOS 9.0, *)
public func coreAnimation<T where T: Subtractable, T: Zeroable>(_ spring: Spring<T>, initialValue: MotionObservable<T>) -> (MotionObservable<T>) {
  return MotionObservable { observer in
    var animationKeys: [String] = []

    let destinationSubscription = spring.destination.subscribe(next: { value in
      let animation = CASpringAnimation()

      animation.damping = spring.friction.value
      animation.stiffness = spring.tension.value

      animation.isAdditive = true

      let from = initialValue.read()!
      let to = value
      let delta = from - to
      animation.fromValue = delta
      animation.toValue = T.zero()

      animation.duration = animation.settlingDuration

      observer.state(.active)
      observer.next(value)
      CATransaction.begin()
      CATransaction.setCompletionBlock {
        observer.state(.atRest)
      }

      let key = NSUUID().uuidString
      animationKeys.append(key)
      observer.coreAnimation(.add(animation, key, initialVelocity: spring.initialVelocity.read()))

      CATransaction.commit()
    }, state: { _ in }, coreAnimation: { _ in })

    return {
      for key in animationKeys {
        observer.coreAnimation(.remove(key))
      }
      destinationSubscription.unsubscribe()
    }
  }
}
