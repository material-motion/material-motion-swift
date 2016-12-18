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

  let aggregator = MotionAggregator()
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

    var destination = card.center.x

    let spring = Spring(to: ScopedReactiveProperty(read: { destination }, write: { destination = $0 }),
                        initialValue: propertyOf(card).centerX,
                        threshold: 1)
    let springStream = popSpringSource(spring)

    aggregator.write(dragStream.onRecognitionState(.ended).velocity(in: view).x(),
                     to: spring.initialVelocity)

    var thisView = view!
    aggregator.write(dragStream.onRecognitionState(.ended).velocity(in: view).x()._map {
      if $0 > 10 {
        return thisView.bounds.width + card.bounds.width
      } else if $0 < -10 {
        return -card.bounds.width
      } else {
        return thisView.bounds.midX
      }
    },
                     to: spring.destination)

    let tap = UITapGestureRecognizer()
    view.addGestureRecognizer(tap)
    aggregator.write(gestureSource(tap).onRecognitionState(.recognized).constant(thisView.bounds.midX),
                     to: spring.destination)

    aggregator.write(springStream.toggled(with: positionStream), to: center)

    let radians = CGFloat(M_PI / 180.0 * 30.0)
    let rotationStream =
      center
      .offset(by: -view.bounds.width / 2)
      .normalized(by: view.bounds.width)
      .scaled(by: CGFloat(radians))
      .bounded(amin: -radians / 2, amax: radians / 2)
    aggregator.write(rotationStream, to: propertyOf(card).rotation)
  }
}
