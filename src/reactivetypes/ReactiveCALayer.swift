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

import IndefiniteObservable
import UIKit

public class ReactiveCALayer {
  public let layer: CALayer

  /** A property representing the layer's .opacity value. */
  public lazy var cornerRadius: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.cornerRadius,
                         externalWrite: { layer.cornerRadius = $0 },
                         keyPath: "cornerRadius")
  }()

  /** A property representing the layer's .opacity value. */
  public lazy var opacity: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: CGFloat(layer.opacity),
                         externalWrite: { layer.opacity = Float($0) },
                         keyPath: "opacity")
  }()

  /** A property representing the layer's .position value. */
  public lazy var position: ReactiveProperty<CGPoint> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.position,
                         externalWrite: { layer.position = $0 },
                         keyPath: "position")
  }()

  /** A property representing the layer's .position.y value. */
  public lazy var positionY: ReactiveProperty<CGFloat> = {
    let position = self.position
    return self.property("\(pretty(self.layer)).\(#function)",
                         initialValue: position.value.y,
                         externalWrite: { var point = position.value; point.y = $0; position.value = point },
                         keyPath: "position.y")
  }()

  /** A property representing the layer's .bounds.size value. */
  public lazy var size: ReactiveProperty<CGSize> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.bounds.size,
                         externalWrite: { layer.bounds.size = $0 },
                         keyPath: "bounds.size")
  }()

  /** A property representing the layer's .anchorPoint value. */
  public lazy var anchorPoint: ReactiveProperty<CGPoint> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.anchorPoint,
                         externalWrite: { layer.anchorPoint = $0 },
                         keyPath: "anchorPoint")
  }()

  /** A property representing the layer's .anchorPoint value. */
  public lazy var anchorPointAdjustment: ReactiveProperty<AnchorPointAdjustment> = {
    let anchorPoint = self.anchorPoint
    let position = self.position
    let layer = self.layer
    return ReactiveProperty("\(pretty(layer)).\(#function)",
                            initialValue: .init(anchorPoint: anchorPoint.value, position: position.value),
                            externalWrite: { anchorPoint.value = $0.anchorPoint; position.value = $0.position },
                            coreAnimation: { _ in })
  }()

  /** A property representing the layer's .transform.rotation.z value. */
  public lazy var rotation: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.value(forKeyPath: "transform.rotation.z") as! CGFloat,
                         externalWrite: { layer.setValue($0, forKeyPath: "transform.rotation.z") },
                         keyPath: "transform.rotation.z")
  }()

  /** A property representing the layer's .transform.scale value. */
  public lazy var scale: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.value(forKeyPath: "transform.scale") as! CGFloat,
                         externalWrite: { layer.setValue($0, forKeyPath: "transform.scale") },
                         keyPath: "transform.scale.xy")
  }()

  /** A property representing the layer's .shadowPath value. */
  public lazy var shadowPath: ReactiveProperty<CGPath> = {
    let layer = self.layer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.shadowPath!,
                         externalWrite: { layer.shadowPath = $0 },
                         keyPath: "shadowPath")
  }()

  fileprivate func property<T>(_ name: String, initialValue: T, externalWrite: @escaping NextChannel<T>, keyPath: String) -> ReactiveProperty<T> {
    let layer = self.layer
    var lastAnimationKey: String?
    let property = ReactiveProperty(name, initialValue: initialValue, externalWrite: externalWrite, coreAnimation: { [weak self] event in
      guard let strongSelf = self else { return }
      switch event {
      case .add(let animation, let key, let initialVelocity, let completionBlock):
        let animation = animation.copy() as! CAPropertyAnimation

        if layer.speed == 0, let lastTimelineState = strongSelf.lastTimelineState {
          animation.beginTime = TimeInterval(lastTimelineState.beginTime) + animation.beginTime
        } else {
          animation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + animation.beginTime
        }

        animation.keyPath = keyPath

        if #available(iOS 9.0, *) {
          // Core Animation springs do not support multi-dimensional velocity, so we bear the burden
          // of decomposing multi-dimensional springs here.
          if let springAnimation = animation as? CASpringAnimation
            , springAnimation.isAdditive
            , let initialVelocity = initialVelocity as? CGPoint
            , let delta = springAnimation.fromValue as? CGPoint {
            let decomposed = decompose(springAnimation: springAnimation,
                                       delta: delta,
                                       initialVelocity: initialVelocity)

            CATransaction.begin()
            CATransaction.setCompletionBlock(completionBlock)
            layer.add(decomposed.0, forKey: key + ".x")
            layer.add(decomposed.1, forKey: key + ".y")
            CATransaction.commit()

            strongSelf.decomposedKeys.insert(key)
            return
          }
        }

        if let initialVelocity = initialVelocity {
          applyInitialVelocity(initialVelocity, to: animation)
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completionBlock)
        layer.add(animation, forKey: key)
        CATransaction.commit()

      case .remove(let key):
        if let presentationLayer = layer.presentation() {
          layer.setValue(presentationLayer.value(forKeyPath: keyPath), forKeyPath: keyPath)
        }
        if strongSelf.decomposedKeys.contains(key) {
          layer.removeAnimation(forKey: key + ".x")
          layer.removeAnimation(forKey: key + ".y")
          strongSelf.decomposedKeys.remove(key)

        } else {
          layer.removeAnimation(forKey: key)
        }

      case .timeline(let timeline):
        strongSelf.timelineSubscription = timeline.subscribe { [weak self] state in
          guard let strongSelf = self else { return }
          strongSelf.lastTimelineState = state

          if state.paused {
            layer.speed = 0
            layer.timeOffset = TimeInterval(state.beginTime + state.timeOffset)

          } else if layer.speed == 0 { // Unpause the layer.
            // The following logic is the magic sauce required to reconnect a CALayer with the
            // render server's clock.
            let pausedTime = layer.timeOffset
            layer.speed = 1
            layer.timeOffset = 0
            layer.beginTime = 0
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
          }
        }
      }
    })
    var lastView: UIView?
    property.visualizer = { view, containerView in
      if lastView != view, let lastView = lastView {
        lastView.removeFromSuperview()
      }
      view.isUserInteractionEnabled = false
      view.frame = layer.superlayer!.convert(layer.superlayer!.bounds, to: containerView.layer)
      containerView.addSubview(view)
      lastView = view
    }

    return property
  }
  private var decomposedKeys = Set<String>()
  private var lastTimelineState: Timeline.Snapshot?
  private var timelineSubscription: Subscription?

  init(_ layer: CALayer) {
    self.layer = layer
  }
}

public class ReactiveCAShapeLayer: ReactiveCALayer {
  public let shapeLayer: CAShapeLayer

  /** A property representing the layer's .path value. */
  public lazy var path: ReactiveProperty<CGPath> = {
    let layer = self.shapeLayer
    return self.property("\(pretty(layer)).\(#function)",
                         initialValue: layer.path!,
                         externalWrite: { layer.path = $0 },
                         keyPath: "path")
  }()

  init(_ shapeLayer: CAShapeLayer) {
    self.shapeLayer = shapeLayer
    super.init(shapeLayer)
  }
}

@available(iOS 9.0, *)
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
  if #available(iOS 9.0, *) {
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
