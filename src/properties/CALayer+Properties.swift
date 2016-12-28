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
    return property(read: { CGFloat(layer.opacity) },
                    write: { layer.opacity = Float($0) },
                    keyPath: "opacity")
  }

  /** A property representing the layer's .position value. */
  public func position() -> ReactiveProperty<CGPoint> {
    let layer = self.layer
    return property(read: { layer.position },
                    write: { layer.position = $0 },
                    keyPath: "position")
  }

  /** A property representing the layer's .position.y value. */
  public func positionY() -> ReactiveProperty<CGFloat> {
    let layer = self.layer
    return property(read: { layer.position.y },
                    write: { layer.position.y = $0 },
                    keyPath: "position.y")
  }

  private func property<T>(read: @escaping ScopedRead<T>, write: @escaping ScopedWrite<T>, keyPath: String) -> ReactiveProperty<T> {
    let layer = self.layer
    var lastAnimationKey: String?
    return ReactiveProperty(read: read, write: write, coreAnimation: { animation in
      animation.keyPath = keyPath
      layer.add(animation, forKey: nil)
    })
  }

  private let layer: CALayer
  fileprivate init(_ layer: CALayer) {
    self.layer = layer
  }
}
