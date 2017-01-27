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
                         keyPath: "transform.scale")
  }()

  private func property<T>(initialValue: T, write: @escaping ScopedWrite<T>, keyPath: String) -> ReactiveProperty<T> {
    let layer = self.layer
    var lastAnimationKey: String?
    return ReactiveProperty(initialValue: initialValue, write: write, coreAnimation: { event in
      switch event {
      case .add(let animation, let key, let initialVelocity):
        if let initialVelocity = initialVelocity {
          applyInitialVelocity(initialVelocity, to: animation)
        }

        animation.keyPath = keyPath
        layer.add(animation, forKey: key)

      case .remove(let key):
        if let presentationLayer = layer.presentation() {
          layer.setValue(presentationLayer.value(forKeyPath: keyPath), forKeyPath: keyPath)
        }
        layer.removeAnimation(forKey: key)
      }
    })
  }

  init(_ layer: CALayer) {
    self.layer = layer
  }
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
