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

public class ReactiveUIView {
  public let view: UIView

  public lazy var isUserInteractionEnabled: ReactiveProperty<Bool> = {
    let view = self.view
    return ReactiveProperty("\(pretty(view)).\(#function)",
                            initialValue: view.isUserInteractionEnabled,
                            externalWrite: { view.isUserInteractionEnabled = $0 })
  }()

  public lazy var backgroundColor: ReactiveProperty<UIColor> = {
    let view = self.view
    return ReactiveProperty("\(pretty(view)).\(#function)",
                            initialValue: view.backgroundColor!,
                            externalWrite: { view.backgroundColor = $0 })
  }()

  public lazy var alpha: ReactiveProperty<CGFloat> = {
    let view = self.view
    return ReactiveProperty("\(pretty(view)).\(#function)",
                            initialValue: view.alpha,
                            externalWrite: { view.alpha = $0 })
  }()

  public lazy var reactiveLayer: ReactiveCALayer = {
    return self.runtime?.get(self.view.layer) ?? ReactiveCALayer(self.view.layer)
  }()

  init(_ view: UIView, runtime: MotionRuntime) {
    self.view = view
    self.runtime = runtime
  }

  private weak var runtime: MotionRuntime?
}
