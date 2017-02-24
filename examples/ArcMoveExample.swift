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

public class ArcMoveExampleViewController: UIViewController {

  var tapCircleLayer: CAShapeLayer!
  var blueSquare: UIView!
  var targetView: UIView!

  var slider: UISlider!
  var toggle: UIButton!

  var runtime: MotionRuntime!
  var timeline = Timeline()
  var duration: MotionObservable<CGFloat>!
  var sliderValue: ReactiveProperty<CGFloat>!

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    self.createViews()
    self.createTimelineViews()

    runtime = MotionRuntime(containerView: view)
    runtime.visualizer = true

    let reactiveTapLayer = runtime.get(tapCircleLayer)
    let reactiveTargetLayer = runtime.get(targetView).reactiveLayer

    let draggable = Draggable()
    draggable.targetView = targetView
    runtime.add(draggable, to: targetView)

    runtime.add(Tap(), to: reactiveTapLayer.position)

    let arcMove = ArcMove(duration: 0.4,
                          from: reactiveTapLayer.position,
                          to: reactiveTargetLayer.position,
                          system: coreAnimation)
    // The duration of the animation is based on the distance to the target
    duration = reactiveTapLayer.position.distance(from: reactiveTargetLayer.position).normalized(by: 600)
    runtime.add(duration, to: arcMove.duration)

    sliderValue = createProperty("Slider.value", withInitialValue: CGFloat(slider.value))
    runtime.add(duration.scaled(by: sliderValue.asStream()), to: timeline.timeOffset)
    timeline.paused.value = true
    arcMove.timeline = timeline
    runtime.add(arcMove, to: blueSquare)
  }

  func createViews() {
    var center = view.center
    center.x -= 32
    center.y -= 32

    blueSquare = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    blueSquare.backgroundColor = UIColor(red: 51/255.0, green: 139/255.0, blue: 237/255.0, alpha: 1)
    view.addSubview(blueSquare)

    tapCircleLayer = CAShapeLayer()
    tapCircleLayer.frame = CGRect(x: center.x - 100, y: center.y - 200, width: 64, height: 64)
    tapCircleLayer.path = UIBezierPath(ovalIn: tapCircleLayer.bounds).cgPath
    tapCircleLayer.lineWidth = 1
    tapCircleLayer.fillColor = UIColor.clear.cgColor
    tapCircleLayer.strokeColor = UIColor(red: 237/255.0, green: 0/255.0, blue: 141/255.0, alpha: 1).cgColor
    view.layer.addSublayer(tapCircleLayer)

    targetView = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    targetView.layer.borderWidth = 1
    targetView.layer.borderColor = UIColor.red.cgColor
    view.addSubview(targetView)
  }

  func createTimelineViews() {
    var center = view.center
    center.x -= 32
    center.y -= 32

    slider = UISlider(frame: .init(x: 0, y: view.bounds.height - 60, width: view.bounds.width, height: 60))
    slider.addTarget(self, action: #selector(didSlide), for: .valueChanged)
    slider.value = 0.5
    view.addSubview(slider)

    toggle = UIButton(type: .custom)
    toggle.setTitle("▶", for: .normal)
    toggle.setTitleColor(.red, for: .normal)
    toggle.addTarget(self, action: #selector(didToggle), for: .touchUpInside)
    toggle.frame = .init(x: 0, y: center.y, width: 64, height: 64)
    view.addSubview(toggle)
  }

  func didSlide(_ slider: UISlider) {
    sliderValue.value = CGFloat(slider.value)
  }

  func didToggle(_ button: UIButton) {
    timeline.paused.value = !timeline.paused.value
    button.setTitle(timeline.paused.value ? "▶" : "❙❙", for: .normal)
  }
}
