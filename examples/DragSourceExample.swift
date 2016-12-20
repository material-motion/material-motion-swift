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

    let gesture = UIPanGestureRecognizer()
    view.addGestureRecognizer(gesture)
    let dragStream = gestureSource(gesture)

    let attach = AttachWithSpring(position: propertyOf(square).center,
                                  to: propertyOf(circle).center,
                                  springSource: popSpringSource)

    aggregator.write(dragStream.onRecognitionState(.ended).velocity(in: view), to: attach.initialVelocity)

    let positionStream = attach.positionStream.toggled(with: dragStream.translated(from: propertyOf(square).center, in: view))
    aggregator.write(positionStream, to: propertyOf(square).center)

    Tap(sets: attach.destination, containerView: view).connect(with: aggregator)
  }
}
