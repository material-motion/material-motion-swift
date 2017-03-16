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

class ArcMoveExampleViewController: ExampleViewController {

  var tapCircleLayer: CAShapeLayer!
  var blueSquare: UIView!
  var targetView: UIView!

  var timelineView: TimelineView!

  var runtime: MotionRuntime!
  var timeline: Timeline!
  var duration: MotionObservable<CGFloat>!
  var sliderValue: ReactiveProperty<CGFloat>!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.createViews()

    timeline = Timeline()
    timelineView = TimelineView(timeline: timeline, frame: .zero)
    let size = timelineView.sizeThatFits(view.bounds.size)
    timelineView.frame = .init(x: 0, y: view.bounds.height - size.height, width: size.width, height: size.height)
    view.addSubview(timelineView)

    runtime = MotionRuntime(containerView: view)
    runtime.shouldVisualizeMotion = true

    let reactiveTapLayer = runtime.get(tapCircleLayer)
    let reactiveTargetLayer = runtime.get(targetView).reactiveLayer

    runtime.add(Draggable(), to: targetView)
    runtime.add(SetPositionOnTap(coordinateSpace: view), to: reactiveTapLayer.position)

    let arcMove = ArcMove()
    runtime.connect(reactiveTapLayer.position, to: arcMove.from)
    runtime.connect(reactiveTargetLayer.position, to: arcMove.to)
    // The duration of the animation is based on the distance to the target
    duration = reactiveTapLayer.position.distance(from: reactiveTargetLayer.position).normalized(by: 600)
    runtime.connect(duration, to: arcMove.tween.duration)

    runtime.connect(duration.scaled(by: timelineView.sliderValue.asStream()), to: timeline.timeOffset)
    timeline.paused.value = true
    runtime.add(arcMove, to: blueSquare)
  }

  func createViews() {
    var center = view.center
    center.x -= 32
    center.y -= 32

    blueSquare = createExampleView()
    blueSquare.frame = .init(x: 0, y: 0, width: blueSquare.bounds.width / 2, height: blueSquare.bounds.height / 2)
    blueSquare.layer.cornerRadius = blueSquare.bounds.width / 2
    view.addSubview(blueSquare)

    tapCircleLayer = CAShapeLayer()
    tapCircleLayer.frame = CGRect(x: center.x - 100, y: center.y - 200, width: blueSquare.bounds.width, height: blueSquare.bounds.height)
    tapCircleLayer.path = UIBezierPath(ovalIn: tapCircleLayer.bounds).cgPath
    tapCircleLayer.lineWidth = 1
    tapCircleLayer.fillColor = UIColor.clear.cgColor
    tapCircleLayer.strokeColor = UIColor.primaryColor.cgColor
    view.layer.addSublayer(tapCircleLayer)

    targetView = UIView(frame: .init(x: center.x, y: center.y, width: blueSquare.bounds.width, height: blueSquare.bounds.height))
    targetView.layer.borderWidth = 1
    targetView.layer.borderColor = UIColor.secondaryColor.cgColor
    view.addSubview(targetView)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Move the squares to change the arc movement.")
  }
}
