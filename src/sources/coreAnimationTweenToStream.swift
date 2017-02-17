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
import IndefiniteObservable

/** Create a core animation tween system for a Tween plan. */
public func coreAnimation<T>(_ tween: Tween<T>) -> MotionObservable<T> {
  return MotionObservable { observer in

    var animationKeys: [String] = []
    var subscriptions: [Subscription] = []
    var activeAnimations = Set<String>()

    var checkAndEmit = {
      let animation: CAPropertyAnimation
      let timingFunctions = tween.timingFunctions
      if tween.values.count > 1 {
        let keyframeAnimation = CAKeyframeAnimation()
        keyframeAnimation.values = tween.values
        keyframeAnimation.keyTimes = tween.keyPositions?.map { NSNumber(value: $0) }
        keyframeAnimation.timingFunctions = timingFunctions
        animation = keyframeAnimation
      } else {
        let basicAnimation = CABasicAnimation()
        basicAnimation.toValue = tween.values.last
        basicAnimation.timingFunction = timingFunctions.first
        animation = basicAnimation
      }
      observer.next(tween.values.last!)

      guard let duration = tween.duration.read() else {
        return
      }
      animation.beginTime = tween.delay
      animation.duration = CFTimeInterval(duration)

      let key = NSUUID().uuidString
      activeAnimations.insert(key)
      animationKeys.append(key)

      tween.state.value = .active

      if let timeline = tween.timeline {
        observer.coreAnimation(.timeline(timeline))
      }
      observer.coreAnimation(.add(animation, key, initialVelocity: nil, completionBlock: {
        activeAnimations.remove(key)
        if activeAnimations.count == 0 {
          tween.state.value = .atRest
        }
      }))
      animationKeys.append(key)
    }

    let activeSubscription = tween.enabled.dedupe().subscribe { enabled in
      if enabled {
        checkAndEmit()
      } else {
        animationKeys.forEach { observer.coreAnimation(.remove($0)) }
        activeAnimations.removeAll()
        animationKeys.removeAll()
        tween.state.value = .atRest
      }
    }

    return {
      animationKeys.forEach { observer.coreAnimation(.remove($0)) }
      subscriptions.forEach { $0.unsubscribe() }
      activeSubscription.unsubscribe()
    }
  }
}
