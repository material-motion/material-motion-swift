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

import UIKit

public class ReactiveCALayer {
  public let layer: CALayer

  /** A property representing the layer's .opacity value. */
  public lazy var opacity: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property(initialValue: CGFloat(layer.opacity),
                         write: { layer.opacity = Float($0) },
                         keyPath: "opacity")
  }()

  /** A property representing the layer's .position value. */
  public lazy var position: ReactiveProperty<CGPoint> = {
    let layer = self.layer
    return self.property(initialValue: layer.position,
                         write: { layer.position = $0 },
                         keyPath: "position")
  }()

  /** A property representing the layer's .position.y value. */
  public lazy var positionY: ReactiveProperty<CGFloat> = {
    let position = self.position
    return self.property(initialValue: position.value.y,
                         write: { var point = position.value; point.y = $0; position.value = point },
                         keyPath: "position.y")
  }()

  /** A property representing the layer's .bounds.size value. */
  public lazy var size: ReactiveProperty<CGSize> = {
    let layer = self.layer
    return self.property(initialValue: layer.bounds.size,
                         write: { layer.bounds.size = $0 },
                         keyPath: "bounds.size")
  }()

  /** A property representing the layer's .anchorPoint value. */
  public lazy var anchorPoint: ReactiveProperty<CGPoint> = {
    let layer = self.layer
    return self.property(initialValue: layer.anchorPoint,
                         write: { layer.anchorPoint = $0 },
                         keyPath: "anchorPoint")
  }()

  /** A property representing the layer's .anchorPoint value. */
  public lazy var anchoring: ReactiveProperty<(CGPoint, CGPoint)> = {
    let anchorPoint = self.anchorPoint
    let position = self.position
    let layer = self.layer
    return ReactiveProperty(initialValue: (anchorPoint.value, position.value),
                            write: { anchorPoint.value = $0.0; position.value = $0.1 },
                            coreAnimation: { _ in })
  }()

  /** A property representing the layer's .transform.rotation.z value. */
  public lazy var rotation: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property(initialValue: layer.value(forKeyPath: "transform.rotation.z") as! CGFloat,
                         write: { layer.setValue($0, forKeyPath: "transform.rotation.z") },
                         keyPath: "transform.rotation.z")
  }()

  /** A property representing the layer's .transform.scale value. */
  public lazy var scale: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return self.property(initialValue: layer.value(forKeyPath: "transform.scale") as! CGFloat,
                         write: { layer.setValue($0, forKeyPath: "transform.scale") },
                         keyPath: "transform.scale.xy")
  }()

  private func property<T>(initialValue: T, write: @escaping ScopedWrite<T>, keyPath: String) -> ReactiveProperty<T> {
    let layer = self.layer
    var lastAnimationKey: String?
    let property = ReactiveProperty(initialValue: initialValue, write: write, coreAnimation: { event in
      switch event {
      case .add(let upstreamAnimation, let key, let initialVelocity):
        let animation = upstreamAnimation.copy() as! CAPropertyAnimation

        if let timeline = self.timeline {
          animation.beginTime = timeline.animationBeginTime(for: layer) + animation.beginTime
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

            layer.add(decomposed.0, forKey: key + ".x")
            layer.add(decomposed.1, forKey: key + ".y")

            self.decomposedKeys.insert(key)
            return
          }
        }

        if let initialVelocity = initialVelocity {
          applyInitialVelocity(initialVelocity, to: animation)
        }

        layer.add(animation, forKey: key)

      case .remove(let key):
        if let presentationLayer = layer.presentation() {
          layer.setValue(presentationLayer.value(forKeyPath: keyPath), forKeyPath: keyPath)
        }
        if self.decomposedKeys.contains(key) {
          layer.removeAnimation(forKey: key + ".x")
          layer.removeAnimation(forKey: key + ".y")
          self.decomposedKeys.remove(key)

        } else {
          layer.removeAnimation(forKey: key)
        }

      case .timeline(let timeline):
        self.timeline = timeline
        timeline.addLayer(layer)
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
  private var timeline: Timeline?

  init(_ layer: CALayer) {
    self.layer = layer
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
