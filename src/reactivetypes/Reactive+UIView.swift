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

extension Reactive where O: UIView {

  public var isUserInteractionEnabled: ReactiveProperty<Bool> {
    let view = _object
    return _properties.named(#function) {
      return .init(initialValue: view.isUserInteractionEnabled) {
        view.isUserInteractionEnabled = $0
      }
    }
  }

  public var backgroundColor: ReactiveProperty<UIColor> {
    let view = _object
    return _properties.named(#function) {
      return .init(initialValue: view.backgroundColor!) {
        view.backgroundColor = $0
      }
    }
  }

  public var alpha: ReactiveProperty<CGFloat> {
    let view = _object
    return _properties.named(#function) {
      return .init(initialValue: view.alpha) {
        view.alpha = $0
      }
    }
  }

  public var layer: Reactive<CALayer> {
    let view = _object
    return Reactive<CALayer>(view.layer)
  }
}
