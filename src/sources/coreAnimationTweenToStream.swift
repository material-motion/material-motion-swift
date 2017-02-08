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

    var keys: [String] = []
    var subscriptions: [Subscription] = []

    var emit = { (animation: CAPropertyAnimation) in
      animation.beginTime = tween.delay
      animation.duration = tween.duration

      observer.state(.active)

      CATransaction.begin()
      CATransaction.setCompletionBlock {
        observer.state(.atRest)
      }

      let key = NSUUID().uuidString
      if let timeline = tween.timeline {
        observer.coreAnimation(.timeline(timeline))
      }
      observer.coreAnimation(.add(animation, key, initialVelocity: nil))
      keys.append(key)

      CATransaction.commit()
    }

    switch tween.mode {
    case .values(let values):
      let animation: CAPropertyAnimation
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
        basicAnimation.timingFunction = timingFunctions.first
        animation = basicAnimation
      }
      observer.next(values.last!)

      emit(animation)

    case .path(let path):
      subscriptions.append(path.subscribe(next: { pathValue in
        let keyframeAnimation = CAKeyframeAnimation()
        keyframeAnimation.path = pathValue
        keyframeAnimation.timingFunctions = tween.timingFunctions

        if let mode = tween.mode as? TweenMode<CGPoint> {
          observer.next(pathValue.getAllPoints().last! as! T)
        } else {
          assertionFailure("Unsupported type \(type(of: T.self))")
        }

        emit(keyframeAnimation)

      }, state: { _ in }, coreAnimation: { _ in }))
    }

    return {
      keys.forEach { observer.coreAnimation(.remove($0)) }
      subscriptions.forEach { $0.unsubscribe() }
    }
  }
}

extension CGPath {

  // Iterates over each registered point in the CGPath. We must use @convention notation to bridge
  // between the swift and objective-c block APIs.
  // Source: http://stackoverflow.com/questions/12992462/how-to-get-the-cgpoints-of-a-cgpath#36374209
  private func forEach(body: @convention(block) (CGPathElement) -> Void) {
    typealias Body = @convention(block) (CGPathElement) -> Void
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
      let body = unsafeBitCast(info, to: Body.self)
      body(element.pointee)
    }
    let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
    self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
  }

  fileprivate func getAllPoints() -> [CGPoint] {
    var arrayPoints: [CGPoint] = []
    self.forEach { element in
      switch (element.type) {
      case .moveToPoint:
        arrayPoints.append(element.points[0])
      case .addLineToPoint:
        arrayPoints.append(element.points[0])
      case .addQuadCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
      case .addCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
        arrayPoints.append(element.points[2])
      default: break
      }
    }
    return arrayPoints
  }
}
