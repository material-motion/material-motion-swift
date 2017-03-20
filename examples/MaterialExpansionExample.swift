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

class MaterialExpansionExampleViewController: ExampleViewController {

  var runtime: MotionRuntime!
  var square: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    square = center(createExampleSquareView(), within: view)
    view.addSubview(square)

    runtime = MotionRuntime(containerView: view)

    let tap = UITapGestureRecognizer()
    tap.addTarget(self, action: #selector(didTap))
    view.addGestureRecognizer(tap)
  }

  // TODO: This should be implemented using a TransitionTween and a toggling tap gesture.
  var expanded = false
  func didTap() {
    if !expanded {
      let widthExpansion = Tween(duration: 0.375, values: [square.bounds.width, square.bounds.width * 2], system: coreAnimation)
      let heightExpansion = Tween(duration: 0.375, values: [square.bounds.height, square.bounds.height * 2], system: coreAnimation)

      widthExpansion.keyPositions.value  = [0, 0.87]
      heightExpansion.keyPositions.value = [0.13, 1.0]

      runtime.add(widthExpansion, to: runtime.get(square.layer).width)
      runtime.add(heightExpansion, to: runtime.get(square.layer).height)
    } else {
      let widthExpansion = Tween(duration: 0.375, values: [square.bounds.width, square.bounds.width / 2], system: coreAnimation)
      let heightExpansion = Tween(duration: 0.375, values: [square.bounds.height, square.bounds.height / 2], system: coreAnimation)

      widthExpansion.keyPositions.value  = [0.13, 1.0]
      heightExpansion.keyPositions.value = [0, 0.87]

      runtime.add(widthExpansion, to: runtime.get(square.layer).width)
      runtime.add(heightExpansion, to: runtime.get(square.layer).height)
    }
    expanded = !expanded
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap anywhere to create an ink ripple.")
  }
}
