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

public class SwipeExampleViewController: UIViewController {

  let runtime = MotionRuntime()
  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let card = UIView(frame: .init(x: 16, y: 16 + 64,
                                   width: view.bounds.size.width - 32,
                                   height: view.bounds.size.height - 32 - 64))
    card.backgroundColor = .red
    view.addSubview(card)

    let dragGesture = UIPanGestureRecognizer()
    view.addGestureRecognizer(dragGesture)

    let dragStream = gestureSource(dragGesture)
    let center = propertyOf(card).centerX

    let positionStream = dragStream
      .translated(from: propertyOf(card).center, in: view)
      .x()

    var destination = createProperty(withInitialValue: card.center.x)

    let spring = Spring(to: destination,
                        initialValue: propertyOf(card).centerX,
                        threshold: 1)
    let springStream = popSpringSource(spring)

    runtime.write(dragStream.onRecognitionState(.ended).velocity(in: view).x(),
                  to: spring.initialVelocity)

    var thisView = view!
    let destinationStream = dragStream
      .onRecognitionState(.ended)
      .velocity(in: view)
      .x()
      .threshold(min: -10, max: 10,
                 whenWithin: thisView.bounds.midX,
                 whenBelow: -card.bounds.width,
                 whenAbove: thisView.bounds.width + card.bounds.width)
    runtime.write(destinationStream, to: spring.destination)

    let tap = UITapGestureRecognizer()
    view.addGestureRecognizer(tap)
    runtime.write(gestureSource(tap).onRecognitionState(.recognized).constant(thisView.bounds.midX),
                  to: spring.destination)

    runtime.write(springStream.toggled(with: positionStream), to: center)

    let radians = CGFloat(M_PI / 180.0 * 15.0)
    let rotationStream =
      center
        .offset(by: -view.bounds.width / 2)
        .normalized(by: view.bounds.width / 2)
        .scaled(by: CGFloat(radians))
    runtime.write(rotationStream, to: propertyOf(card).rotation)
  }
}
