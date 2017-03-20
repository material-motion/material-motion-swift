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

class ArcMoveExampleViewController: ExampleViewController, TimelineViewDelegate {

  var runtime: MotionRuntime!
  var timeline: Timeline!

  override func viewDidLoad() {
    super.viewDidLoad()

    var center = view.center
    center.x -= 32
    center.y -= 32

    let blueSquare = createExampleView()
    blueSquare.frame = .init(x: 0, y: 0, width: blueSquare.bounds.width / 2, height: blueSquare.bounds.height / 2)
    blueSquare.layer.cornerRadius = blueSquare.bounds.width / 2
    view.addSubview(blueSquare)

    let circle = UIView()
    circle.frame = CGRect(x: center.x - 100, y: center.y - 200, width: blueSquare.bounds.width, height: blueSquare.bounds.height)
    circle.layer.cornerRadius = circle.bounds.width / 2
    circle.layer.borderColor = UIColor.primaryColor.cgColor
    circle.layer.borderWidth = 1
    view.addSubview(circle)

    let targetView = UIView(frame: .init(x: center.x, y: center.y, width: blueSquare.bounds.width, height: blueSquare.bounds.height))
    targetView.layer.borderWidth = 1
    targetView.layer.borderColor = UIColor.secondaryColor.cgColor
    view.addSubview(targetView)

    let timelineView = TimelineView()
    timelineView.delegate = self
    let size = timelineView.sizeThatFits(view.bounds.size)
    timelineView.frame = .init(x: 0, y: view.bounds.height - size.height, width: size.width, height: size.height)
    view.addSubview(timelineView)

    timeline = Timeline()

    timelineView.timeline = timeline

    runtime = MotionRuntime(containerView: view)
    runtime.shouldVisualizeMotion = true

    runtime.add(Draggable(), to: circle)
    runtime.add(Draggable(), to: targetView)

    let arcMove = ArcMove(tween: .init(timeline: timeline))
    arcMove.tween.duration.value = 0.4
    runtime.connect(runtime.get(circle.layer).position, to: arcMove.from)
    runtime.connect(runtime.get(targetView.layer).position, to: arcMove.to)

    timeline.paused.value = true

    runtime.add(arcMove, to: blueSquare)
  }

  func timelineView(_ timelineView: TimelineView, didChangeSliderValue sliderValue: CGFloat) {
    timeline.timeOffset.value = sliderValue * 0.4
  }

  func timelineViewDidTogglePause(_ timelineView: TimelineView) {
    timeline.paused.value = !timeline.paused.value
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Move the squares to change the arc movement.")
  }
}
