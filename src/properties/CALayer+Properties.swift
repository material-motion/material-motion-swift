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

  /** A property representing the layer's .position value. */
  public func position() -> ReactiveProperty<CGPoint> {
    let layer = self.layer
    return ReactiveProperty(read: { layer.position }, write: { layer.position = $0 })
  }

  /** A property representing the layer's .position value. */
  @available(iOS 9.0, *)
  public func position<O>() -> ReactiveProperty<(O, CGPoint)> where O: CAPropertyAnimation {
    return coreAnimationProperty(keyPath: "position")
  }

  /** A property representing the layer's .position.x value. */
  @available(iOS 9.0, *)
  public func positionX<O>() -> ReactiveProperty<(O, CGFloat)> where O: CAPropertyAnimation {
    return coreAnimationProperty(keyPath: "position.x")
  }

  /** A property representing the layer's .position.y value. */
  @available(iOS 9.0, *)
  public func positionY<O>() -> ReactiveProperty<(O, CGFloat)> where O: CAPropertyAnimation {
    return coreAnimationProperty(keyPath: "position.y")
  }

  private func coreAnimationProperty<O, T>(keyPath: String) -> ReactiveProperty<(O, T)> where O: CAPropertyAnimation, T: Zeroable {
    let layer = self.layer
    var lastAnimationKey: String?
    return ReactiveProperty(read: {

      // Return the latest model value and the last written animation, if available.

      if let lastAnimationKey = lastAnimationKey, let animation = layer.animation(forKey: lastAnimationKey) {
        let value = layer.value(forKeyPath: keyPath) as! T
        return (animation as! O, value)
      } else {
        assertionFailure("No animation information presently available for \(keyPath)")
        return (O() as! O, T.zero() as! T)
      }

    }, write: { animation, modelValue in
      animation.keyPath = keyPath
      let key = NSUUID().uuidString
      lastAnimationKey = key
      layer.add(animation, forKey: key)
      layer.setValue(modelValue, forKeyPath: animation.keyPath!)
    })
  }

  private let layer: CALayer
  fileprivate init(_ layer: CALayer) {
    self.layer = layer
  }
}
