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

public class Tossable2 {
  public init(_ view: UIView, relativeTo: UIView) {
    let draggable = Draggable2(view, containerView: relativeTo)

    let spring = Spring2(for: Reactive(view.layer).position)

    draggable.gesture.didBegin().subscribeToValue { _ in
      spring.stop()
    }
    draggable.gesture.didAnything._filter { $0.state == .ended }.velocity(in: view).subscribeToValue { velocity in
      spring.initialVelocity = velocity
      spring.start()
    }

    self.draggable = draggable
    self.spring = spring
  }

  public let draggable: Draggable2
  public let spring: Spring2<CGPoint>
}

class TossableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleSquareView(), within: view)
    view.addSubview(square)

    let tossable = Tossable2(square, relativeTo: view)
    tossable.spring.destination = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Use two fingers to rotate the view.")
  }
}
