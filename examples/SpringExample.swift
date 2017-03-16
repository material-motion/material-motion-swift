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
import ReactiveMotion

class SpringExampleViewController: ExampleViewController {

  var runtime: MotionRuntime!

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    runtime = MotionRuntime(containerView: view)

    let spring = Spring<CGFloat>(threshold: 0.01, system: coreAnimation)
    spring.destination.value = 1
    runtime.add(spring, to: runtime.get(square.layer).scale)

    let tap = runtime.get(UITapGestureRecognizer())
    runtime.connect(tap.whenRecognitionState(is: .recognized).rewriteTo(1.5), to: spring.destination)
    runtime.connect(tap.whenRecognitionState(is: .recognized).delay(by: 0.1).rewriteTo(1), to: spring.destination)

    runtime.whenAllAtRest([spring]) {
      print("Is now at rest")
    }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap anywhere to move the view.")
  }
}
