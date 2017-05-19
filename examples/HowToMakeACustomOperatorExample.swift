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
import MaterialMotion

class HowToMakeACustomOperatorExampleViewController: ExampleViewController {

  var runtime: MotionRuntime!

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    runtime = MotionRuntime(containerView: view)
    runtime.add(Draggable(), to: square) { $0.wobble(width: 100) }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Drag up and down to wobble the square.")
  }
}

extension MotionObservableConvertible where T == CGPoint {

  fileprivate func wobble(width: CGFloat) -> MotionObservable<CGPoint> {
    return _map { .init(x: $0.x + sin($0.y / 50) * width, y: $0.y) }
  }
}
