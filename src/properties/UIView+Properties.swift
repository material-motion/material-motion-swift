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
public func propertyOf(_ view: UIView) -> UIViewReactivePropertyBuilder {
  return UIViewReactivePropertyBuilder(view)
}

/** A scoped property builder for UIView instances. */
public class UIViewReactivePropertyBuilder {

  /** A property representing the view's .alpha value. */
  public var alpha: ReactiveProperty<CGFloat> {
    let view = self.view
    return ReactiveProperty(read: { view.alpha }, write: { view.alpha = $0 })
  }

  /** A property representing the view's .center.x value. */
  public var centerX: ReactiveProperty<CGFloat> {
    let view = self.view
    return ReactiveProperty(read: { view.center.x }, write: { view.center.x = $0 })
  }

  /** A property representing the view's .center.y value. */
  public var centerY: ReactiveProperty<CGFloat> {
    let view = self.view
    return ReactiveProperty(read: { view.center.y }, write: { view.center.y = $0 })
  }

  /** A property representing the view's .center value. */
  public var center: ReactiveProperty<CGPoint> {
    let view = self.view
    return ReactiveProperty(read: { view.center }, write: { view.center = $0 })
  }

  /** A property representing the view's transform.rotation.z value. */
  public var rotation: ReactiveProperty<CGFloat> {
    let view = self.view
    return ReactiveProperty(read: { view.value(forKeyPath: "layer.transform.rotation.z") as! CGFloat },
                            write: { view.setValue($0, forKeyPath: "layer.transform.rotation.z") })
  }

  private let view: UIView
  fileprivate init(_ view: UIView) {
    self.view = view
  }
}
