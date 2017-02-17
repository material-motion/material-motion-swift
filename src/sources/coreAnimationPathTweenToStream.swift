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
public func coreAnimation(_ tween: PathTween) -> MotionObservable<CGPoint> {
  return MotionObservable { observer in

    var animationKeys: [String] = []
    var subscriptions: [Subscription] = []
    var activeAnimations = Set<String>()

    var checkAndEmit = {
      subscriptions.append(tween.path.subscribe { pathValue in
        let animation = CAKeyframeAnimation()
        animation.path = pathValue

        observer.next(pathValue.getAllPoints().last!)

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

      })
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
