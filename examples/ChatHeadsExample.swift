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
import MaterialMotionStreams

@available(iOS 9.0, *)
public class ChatHeadsExampleViewController: UIViewController {

  var runtime: MotionRuntime!
  public override func viewDidLoad() {
    super.viewDidLoad()

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = .white

    var center = view.center
    center.x -= 32
    center.y -= 32

    let circle = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    circle.backgroundColor = .blue
    circle.layer.cornerRadius = circle.bounds.width / 2
    view.addSubview(circle)

    let destination = Destination(.init(x: circle.bounds.width / 2 - 8, y: center.y))
    let tossable = Tossable(destination: destination, system: coreAnimation)
    tossable.draggable.relativeView = circle
    tossable.draggable.targetView = circle

    let gesture = runtime.get(tossable.draggable.gestureRecognizer)
    runtime.add(gesture.onRecognitionState(.ended)
      .closestEdge(in: view.bounds.insetBy(dx: circle.bounds.width / 2 - 8,
                                           dy: circle.bounds.width / 2 - 8)),
                to: destination)

    runtime.add(tossable, to: circle)
  }
}
