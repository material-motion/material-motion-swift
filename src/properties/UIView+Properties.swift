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

/** Retrieve a scoped property builder for the given UIView. */
public func propertyOf(_ view: UIView) -> UIViewScopedReactivePropertyBuilder {
  return UIViewScopedReactivePropertyBuilder(view)
}

/** A scoped property builder for UIView instances. */
public class UIViewScopedReactivePropertyBuilder {

  /** A property representing the view's .alpha value. */
  public var alpha: ScopedReactiveProperty<CGFloat> {
    let view = self.view
    return ScopedReactiveProperty(read: { view.alpha }, write: { view.alpha = $0 })
  }

  /** A property representing the view's .center.x value. */
  public var centerX: ScopedReactiveProperty<CGFloat> {
    let view = self.view
    return ScopedReactiveProperty(read: { view.center.x }, write: { view.center.x = $0 })
  }

  /** A property representing the view's .center.y value. */
  public var centerY: ScopedReactiveProperty<CGFloat> {
    let view = self.view
    return ScopedReactiveProperty(read: { view.center.y }, write: { view.center.y = $0 })
  }

  /** A property representing the view's .center value. */
  public var center: ScopedReactiveProperty<CGPoint> {
    let view = self.view
    return ScopedReactiveProperty(read: { view.center }, write: { view.center = $0 })
  }

  public var rotation: ScopedReactiveProperty<CGFloat> {
    let view = self.view
    return ScopedReactiveProperty(read: { view.value(forKeyPath: "layer.transform.rotation.z") as! CGFloat },
                          write: { view.setValue($0, forKeyPath: "layer.transform.rotation.z") })
  }

  private let view: UIView
  fileprivate init(_ view: UIView) {
    self.view = view
  }
}
