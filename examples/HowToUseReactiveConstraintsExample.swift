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

class HowToUseReactiveConstraintsExampleViewController: ExampleViewController {

  var runtime: MotionRuntime!

  override func viewDidLoad() {
    super.viewDidLoad()

    let exampleView = center(createExampleView(), within: view)
    view.addSubview(exampleView)

    let axisLine = UIView(frame: .init(x: view.bounds.midX - 8, y: 0, width: 16, height: view.bounds.height))
    axisLine.backgroundColor = .secondaryColor
    view.insertSubview(axisLine, belowSubview: exampleView)

    runtime = MotionRuntime(containerView: view)

    let axisCenterX = runtime.get(axisLine.layer).position.x()
    runtime.add(Draggable(), to: exampleView) { $0
      .startWith(exampleView.layer.position)
      .xLocked(to: axisCenterX)
    }

    runtime.add(Draggable(), to: axisLine) { $0.yLocked(to: axisLine.layer.position.y) }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Drag the view to move it on the y axis.")
  }
}
