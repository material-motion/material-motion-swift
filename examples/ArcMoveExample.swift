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
import IndefiniteObservable
import MaterialMotionStreams

public class ArcMoveExampleViewController: UIViewController {

  var runtime: MotionRuntime!
  let timeline = Timeline()
  public override func viewDidLoad() {
    super.viewDidLoad()

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = .white

    var center = view.center
    center.x -= 32
    center.y -= 32

    let square = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    square.backgroundColor = .red
    view.addSubview(square)

    let square2 = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    square2.backgroundColor = .green
    view.addSubview(square2)

    let circle = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    circle.backgroundColor = .blue
    circle.layer.cornerRadius = circle.bounds.width / 2
    view.addSubview(circle)

    let slider = UISlider(frame: .init(x: 0, y: view.bounds.height - 60, width: view.bounds.width, height: 60))
    slider.addTarget(self, action: #selector(didSlide), for: .valueChanged)
    slider.value = 0.5
    view.addSubview(slider)

    let toggle = UIButton(type: .contactAdd)
    toggle.addTarget(self, action: #selector(didToggle), for: .touchUpInside)
    toggle.frame = .init(x: 0, y: 200, width: 64, height: 64)
    view.addSubview(toggle)

    runtime.add(Draggable(), to: square)

    timeline.timeOffset.value = Double(slider.value) * 0.4
    timeline.paused.value = true

    let path = arcMove(from: runtime.get(square.layer).position,
                       to: runtime.get(circle.layer).position)
    let tween = Tween<CGPoint>(duration: 0.4, path: path, system: coreAnimation)
    tween.timeline = timeline
    runtime.add(tween, to: runtime.get(square2.layer).position)
  }

  func didSlide(_ slider: UISlider) {
    timeline.timeOffset.value = TimeInterval(slider.value * 0.4)
  }

  func didToggle() {
    timeline.paused.value = !timeline.paused.value
  }
}
