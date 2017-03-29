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

class ChangeDirectionOnReleaseExampleViewController: ExampleViewController {

  var runtime: MotionRuntime!

  override func viewDidLoad() {
    super.viewDidLoad()

    let targetView = center(createExampleSquareView(), within: view)
    targetView.layer.borderColor = targetView.backgroundColor?.cgColor
    targetView.layer.borderWidth = 1
    targetView.backgroundColor = nil
    view.addSubview(targetView)

    let exampleView = center(createExampleView(), within: view)
    view.addSubview(exampleView)

    runtime = MotionRuntime(containerView: view)

    let direction = createProperty(withInitialValue: TransitionDirection.backward)

    let positionSpring = TransitionSpring(back: CGPoint(x: view.bounds.midX, y: view.bounds.height * 4 / 10),
                                          fore: CGPoint(x: view.bounds.midX, y: view.bounds.height * 6 / 10),
                                          direction: direction)
    let tossable = Tossable(spring: positionSpring)
    runtime.add(ChangeDirection(withVelocityOf: tossable.draggable.nextGestureRecognizer,
                                         whenNegative: .backward,
                                         whenPositive: .forward),
                to: direction)
    runtime.add(tossable, to: exampleView)
    runtime.add(positionSpring, to: runtime.get(targetView.layer).position)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Toss the view to change its position.")
  }
}
