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

extension MotionObservableConvertible {

  /** Transform the items emitted by an Observable by applying a function to each item. */
  func _map<U>(_ metadata: Metadata, transform: @escaping (T) -> U) -> MotionObservable<U> {
    return asStream()._nextOperator(metadata, operation: { value, next in
      next(transform(value))

    }, coreAnimation: { event, coreAnimation in
      let transformedInitialVelocity: Any?
      switch event {
      case .add(let animation, let key, let initialVelocity, let completionBlock):
        if let initialVelocity = initialVelocity {
          transformedInitialVelocity = transform(initialVelocity as! T)
        } else {
          transformedInitialVelocity = nil
        }

        let copy = animation.copy() as! CAPropertyAnimation
        switch copy {
        case let basicAnimation as CABasicAnimation:
          if let fromValue = basicAnimation.fromValue {
            basicAnimation.fromValue = transform(fromValue as! T)
          }
          if let toValue = basicAnimation.toValue {
            basicAnimation.toValue = transform(toValue as! T)
          }
          if let byValue = basicAnimation.byValue {
            basicAnimation.byValue = transform(byValue as! T)
          }
          coreAnimation(.add(basicAnimation, key, initialVelocity: transformedInitialVelocity, completionBlock: completionBlock))

        case let keyframeAnimation as CAKeyframeAnimation:
          keyframeAnimation.values = keyframeAnimation.values?.map { transform($0 as! T) }
          coreAnimation(.add(keyframeAnimation, key, initialVelocity: transformedInitialVelocity, completionBlock: completionBlock))

        default:
          assertionFailure("Unsupported animation type: \(type(of: animation))")
        }

      default:
        coreAnimation(event)
      }
    })
  }
}
