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
import IndefiniteObservable

public final class CoreAnimationKeyPath<T> {
  init(_ keyPath: String, onLayer layer: CALayer, property: ReactiveProperty<T>) {
    self.keyPath = keyPath
    self.layer = layer
    self.property = property
  }

  public let property: ReactiveProperty<T>

  private let keyPath: String
  private weak var layer: CALayer?

  public func removeAnimation(forKey key: String) {
    guard let layer = layer else { return }

    layer.removeAnimation(forKey: key)
  }

  public func add(_ animation: CAPropertyAnimation, forKey key: String) {
    switch animation {
    case let animation as CABasicAnimation: add(animation, forKey: key)
    case let animation as CAKeyframeAnimation: add(animation, forKey: key)
    case let animation as CASpringAnimation: add(animation, forKey: key)
    default:
      break
    }
  }

  public func add(_ animation: CABasicAnimation, forKey key: String) {
    guard let layer = layer else { return }

    let animation = prepare(animation, withLayer: layer)

    if let makeAdditive = getMakeAdditive(animation.fromValue!) {
      animation.fromValue = makeAdditive(animation.fromValue!, animation.toValue!)
      animation.toValue = makeAdditive(animation.toValue!, animation.toValue!)
      animation.isAdditive = true
    }

    CATransaction.begin()
    layer.add(animation, forKey: key)
    CATransaction.commit()
  }

  public func add(_ animation: CASpringAnimation, forKey key: String, initialVelocity: Any?) {
    guard let layer = layer else { return }

    let animation = prepare(animation, withLayer: layer)

    if let makeAdditive = getMakeAdditive(animation.fromValue!) {
      animation.fromValue = makeAdditive(animation.fromValue!, animation.toValue!)
      animation.toValue = makeAdditive(animation.toValue!, animation.toValue!)
      animation.isAdditive = true
    }

    // Core Animation springs do not support multi-dimensional velocity, so we decompose to a
    // multi-dimensional spring here.
    if let springAnimation = animation as? CASpringAnimation
      , springAnimation.isAdditive
      , let initialVelocity = initialVelocity as? CGPoint
      , let delta = springAnimation.fromValue as? CGPoint {
      let decomposed = decompose(springAnimation: springAnimation,
                                 delta: delta,
                                 initialVelocity: initialVelocity)

      CATransaction.begin()
      layer.add(decomposed.0, forKey: key + ".x")
      layer.add(decomposed.1, forKey: key + ".y")
      CATransaction.commit()
      return
    }

    if let initialVelocity = initialVelocity {
      applyInitialVelocity(initialVelocity, to: animation)
    }

    CATransaction.begin()
    layer.add(animation, forKey: key)
    CATransaction.commit()
  }

  public func add(_ animation: CAKeyframeAnimation, forKey key: String) {
    guard let layer = layer else { return }

    let animation = prepare(animation, withLayer: layer)

    let lastValue = animation.values!.last!
    if let makeAdditive = getMakeAdditive(lastValue) {
      animation.values = animation.values!.map { makeAdditive($0, lastValue) }
      animation.isAdditive = true
    }

    CATransaction.begin()
    layer.add(animation, forKey: key)
    CATransaction.commit()
  }

  private func prepare<T>(_ animation: T, withLayer layer: CALayer) -> T where T: CAPropertyAnimation {
    let animation = animation.copy() as! T

    animation.keyPath = keyPath

    animation.duration *= TimeInterval(simulatorDragCoefficient())

    if layer.speed == 0, let lastTimelineState = layer.lastTimelineState {
      animation.beginTime = TimeInterval(lastTimelineState.beginTime) + animation.beginTime
    } else {
      animation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + animation.beginTime
    }

    return animation
  }

  private func getMakeAdditive(_ value: Any) -> ((Any, Any) -> Any)? {
    switch value {

    case is CGFloat:
      return { from, to in
        return (from as! CGFloat) - (to as! CGFloat)
      }

    case is CGPoint:
      return { from, to in
        let from = from as! CGPoint
        let to = to as! CGPoint
        return CGPoint(x: from.x - to.x, y: from.y - to.y)
      }

    case is NSNumber:
      // When mapping properties to properties it's possible for the values to get implicitly
      // wrapped in an NSNumber instance. This may cause the generic makeAdditive
      // implementation to fail to cast to T, so we unbox the type here instead.
      return { from, to in
        return (from as! NSNumber).doubleValue - (to as! NSNumber).doubleValue
      }

    default:
      return nil
    }
  }

  private func decompose(springAnimation: CASpringAnimation, delta: CGPoint, initialVelocity: CGPoint) -> (CASpringAnimation, CASpringAnimation) {
    let xAnimation = springAnimation.copy() as! CASpringAnimation
    let yAnimation = springAnimation.copy() as! CASpringAnimation
    xAnimation.fromValue = delta.x
    yAnimation.fromValue = delta.y
    xAnimation.toValue = 0
    yAnimation.toValue = 0

    if delta.x != 0 {
      xAnimation.initialVelocity = initialVelocity.x / -delta.x
    }
    if delta.y != 0 {
      yAnimation.initialVelocity = initialVelocity.y / -delta.y
    }

    xAnimation.keyPath = springAnimation.keyPath! + ".x"
    yAnimation.keyPath = springAnimation.keyPath! + ".y"
    
    return (xAnimation, yAnimation)
  }

  private func applyInitialVelocity(_ initialVelocity: Any, to animation: CAPropertyAnimation) {
    if let springAnimation = animation as? CASpringAnimation, springAnimation.isAdditive {
      // Additive animations have a toValue of 0 and a fromValue of negative delta (where the model
      // value came from).
      guard let initialVelocity = initialVelocity as? CGFloat, let delta = springAnimation.fromValue as? CGFloat else {
        // Unsupported velocity type.
        return
      }
      if delta != 0 {
        // CASpringAnimation's initialVelocity is proportional to the distance to travel, i.e. our
        // delta.
        springAnimation.initialVelocity = initialVelocity / -delta
      }
    }
  }
}
