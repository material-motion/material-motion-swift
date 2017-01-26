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

/** Retrieve a scoped property builder for the given CALayer. */
public func propertyOf(_ layer: CALayer) -> CALayerReactivePropertyBuilder {
  return CALayerReactivePropertyBuilder(layer)
}

/** A scoped property builder for CALayer instances. */
public class CALayerReactivePropertyBuilder {

  /** A property representing the layer's .opacity value. */
  public func opacity() -> ReactiveProperty<CGFloat> {
    let layer = self.layer
    return property(initialValue: CGFloat(layer.opacity),
                    write: { layer.opacity = Float($0) },
                    keyPath: "opacity")
  }

  /** A property representing the layer's .position value. */
  public func position() -> ReactiveProperty<CGPoint> {
    let layer = self.layer
    return property(initialValue: layer.position,
                    write: { layer.position = $0 },
                    keyPath: "position")
  }

  /** A property representing the layer's .position.y value. */
  public func positionY() -> ReactiveProperty<CGFloat> {
    let layer = self.layer
    return property(initialValue: layer.position.y,
                    write: { layer.position.y = $0 },
                    keyPath: "position.y")
  }

  /** A property representing the layer's .anchorPoint value. */
  public func anchorPoint() -> ReactiveProperty<CGPoint> {
    let layer = self.layer
    return property(initialValue: layer.anchorPoint,
                    write: { changeAnchorPoint(of: layer, to: $0) },
                    keyPath: "anchorPoint")
  }

  /** A property representing the layer's .transform.rotation.z value. */
  public func rotation() -> ReactiveProperty<CGFloat> {
    let layer = self.layer
    return property(initialValue: layer.value(forKeyPath: "transform.rotation.z") as! CGFloat,
                    write: { layer.setValue($0, forKeyPath: "transform.rotation.z") },
                    keyPath: "transform.rotation.z")
  }

  /** A property representing the layer's .transform.scale value. */
  public func scale() -> ReactiveProperty<CGFloat> {
    let layer = self.layer
    return property(initialValue: layer.value(forKeyPath: "transform.scale") as! CGFloat,
                    write: { layer.setValue($0, forKeyPath: "transform.scale") },
                    keyPath: "transform.scale")
  }

  private func property<T>(initialValue: T, write: @escaping ScopedWrite<T>, keyPath: String) -> ReactiveProperty<T> {
    let layer = self.layer
    var lastAnimationKey: String?
    return ReactiveProperty(initialValue: initialValue, write: write, coreAnimation: { event in
      switch event {
      case .add(let animation, let key, let modelValue, let initialVelocity):
        if let initialVelocity = initialVelocity {
          applyInitialVelocity(initialVelocity, to: animation)
        }

        animation.keyPath = keyPath
        layer.setValue(modelValue, forKeyPath: keyPath)
        layer.add(animation, forKey: key)

      case .remove(let key):
        if let presentationLayer = layer.presentation() {
          layer.setValue(presentationLayer.value(forKeyPath: keyPath), forKeyPath: keyPath)
        }
        layer.removeAnimation(forKey: key)
      }
    })
  }

  private let layer: CALayer
  fileprivate init(_ layer: CALayer) {
    self.layer = layer
  }
}

/**
 Changes the anchor point of a given layer to the provided anchorPoint while maintaining the layer's
 frame.

 @param anchorPoint The new anchor point, expressed in the [0,1] range for each x and y value.
 0 corresponds to the min value of the bounds' corresponding axis.
 1 corresponds to the max value of the bounds' corresponding axis.
 */
private func changeAnchorPoint(of layer: CALayer, to anchorPoint: CGPoint) {
  let newPosition = CGPoint(x: anchorPoint.x * layer.bounds.width,
                            y: anchorPoint.y * layer.bounds.height)

  let positionInSuperview = layer.convert(newPosition, to: layer.superlayer)

  layer.anchorPoint = anchorPoint
  layer.position = positionInSuperview
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
