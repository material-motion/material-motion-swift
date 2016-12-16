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

// This example demonstrates how to connect a drag source to a property on a view.

protocol Interaction {
  func connect(with aggregator: MotionAggregator)
}

class Tossable: Interaction {
  let spring: Spring<CGPoint>
  let viewToToss: UIView

  let destination: ScopedProperty<CGPoint>
  var positionStream: MotionObservable<CGPoint>
  var initialVelocityStream: MotionObservable<CGPoint>

  init(destination: ScopedProperty<CGPoint>,
       viewToToss: UIView,
       containerView: UIView,
       springSource: (Spring<CGPoint>) -> MotionObservable<CGPoint>) {
    self.destination = destination
    self.viewToToss = viewToToss

    let dragGesture = UIPanGestureRecognizer()
    containerView.addGestureRecognizer(dragGesture)

    let dragStream = gestureSource(dragGesture)

    let initialPosition = propertyOf(viewToToss).center
    let translationStream = dragStream.translated(from: initialPosition, in: containerView)

    self.initialVelocityStream = dragStream.onRecognitionState(.ended).velocity(in: containerView)

    self.spring = Spring(to: destination, initialValue: initialPosition, threshold: 1)
    let springStream = springSource(spring)
    self.positionStream = springStream.toggled(with: translationStream)
  }

  func connect(with aggregator: MotionAggregator) {
    aggregator.write(initialVelocityStream, to: spring.initialVelocity)
    aggregator.write(positionStream, to: propertyOf(viewToToss).center)
  }
}

class TapToChangeDestination: Interaction {
  let destination: ScopedProperty<CGPoint>

  var tapStream: MotionObservable<CGPoint>
  init(destination: ScopedProperty<CGPoint>, containerView: UIView) {
    self.destination = destination

    let tap = UITapGestureRecognizer()
    containerView.addGestureRecognizer(tap)

    self.tapStream = gestureSource(tap).onRecognitionState(.recognized).centroid(in: containerView)
  }

  func connect(with aggregator: MotionAggregator) {
    aggregator.write(tapStream, to: destination)
  }
}

public class DragSourceExampleViewController: UIViewController {

  let aggregator = MotionAggregator()
  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let square = UIView(frame: .init(x: 0, y: 0, width: 64, height: 64))
    square.backgroundColor = .red
    view.addSubview(square)

    let circle = UIView(frame: .init(x: 0, y: 0, width: 64, height: 64))
    circle.backgroundColor = .blue
    circle.layer.cornerRadius = circle.bounds.width / 2
    view.addSubview(circle)

    let tossable = Tossable(destination: propertyOf(circle).center,
                            viewToToss: square,
                            containerView: view,
                            springSource: popSpringSource)
    tossable.connect(with: aggregator)

    TapToChangeDestination(destination: tossable.destination, containerView: view)
      .connect(with: aggregator)
  }
}
