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

/** Create a core animation tween source for a Tween plan. */
public func coreAnimationTweenSource<T>(_ tween: Tween<T>) -> MotionObservable<T> {
  return MotionObservable { observer in
    let animation: CAPropertyAnimation

    let values = tween.values
    let timingFunctions = tween.timingFunctions

    if values.count > 1 {
      let keyframeAnimation = CAKeyframeAnimation()
      keyframeAnimation.values = values
      keyframeAnimation.keyTimes = tween.keyPositions?.map { NSNumber(value: $0) }
      keyframeAnimation.timingFunctions = timingFunctions
      animation = keyframeAnimation
    } else {
      let basicAnimation = CABasicAnimation()
      basicAnimation.toValue = values.last
      basicAnimation.timingFunction = timingFunctions?.first
      animation = basicAnimation
    }
    animation.duration = tween.duration

    observer.state(.active)
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      observer.state(.atRest)
    }

    observer.next(values.last!)
    let key = NSUUID().uuidString
    observer.coreAnimation(.add(animation, key, initialVelocity: nil))

    CATransaction.commit()

    return {
      observer.coreAnimation(.remove(key))
    }
  }
}
