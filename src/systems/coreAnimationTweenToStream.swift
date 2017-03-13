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
public func coreAnimation<T>(_ tween: TweenShadow<T>) -> MotionObservable<T> {
  return MotionObservable(Metadata("Core Animation Tween", args: [tween])) { observer in

    var animationKeys: [String] = []
    var activeAnimations = Set<String>()

    let checkAndEmit = {
      let animation: CAPropertyAnimation
      let timingFunctions = tween.timingFunctions
      if tween.values.value.count > 1 {
        let keyframeAnimation = CAKeyframeAnimation()
        keyframeAnimation.values = tween.values.value
        keyframeAnimation.keyTimes = tween.keyPositions.value.map { NSNumber(value: Double($0)) }
        keyframeAnimation.timingFunctions = timingFunctions.value
        animation = keyframeAnimation
      } else {
        let basicAnimation = CABasicAnimation()
        basicAnimation.toValue = tween.values.value.last
        basicAnimation.timingFunction = timingFunctions.value.first
        animation = basicAnimation
      }
      observer.next(tween.values.value.last!)

      guard let duration = tween.duration._read() else {
        return
      }
      animation.beginTime = CFTimeInterval(tween.delay.value)
      animation.duration = CFTimeInterval(duration)

      let key = NSUUID().uuidString
      activeAnimations.insert(key)
      animationKeys.append(key)

      tween.state.value = .active

      var info = CoreAnimationChannelAdd(animation: animation, key: key, onCompletion: {
        activeAnimations.remove(key)
        if activeAnimations.count == 0 {
          tween.state.value = .atRest
        }
      })
      info.timeline = tween.timeline
      observer.coreAnimation?(.add(info))
      animationKeys.append(key)
    }

    let activeSubscription = tween.enabled.dedupe().subscribeToValue { enabled in
      if enabled {
        checkAndEmit()
      } else {
        animationKeys.forEach { observer.coreAnimation?(.remove($0)) }
        activeAnimations.removeAll()
        animationKeys.removeAll()
        tween.state.value = .atRest
      }
    }

    return {
      animationKeys.forEach { observer.coreAnimation?(.remove($0)) }
      activeSubscription.unsubscribe()
    }
  }
}
