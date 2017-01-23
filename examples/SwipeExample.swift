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

enum TossDirection {
  case none
  case left
  case right
}

class TossableStackedCard: Interaction {
  public let view: UIView
  public let tossDirection = createProperty(withInitialValue: TossDirection.none)

  init(view: UIView, containerView: UIView, previousCard: TossableStackedCard? = nil, rotation: CGFloat) {
    self.view = view
    self.containerView = containerView
    self.previousCard = previousCard
    self.rotation = rotation

    self.dragGesture = UIPanGestureRecognizer()

    position = propertyOf(view).centerX
  }

  func connect(with runtime: MotionRuntime) {
    view.addGestureRecognizer(dragGesture)

    let destination = createProperty(withInitialValue: containerView.bounds.midX)
    let attachment = AttachWithSpring(property: position,
                                      to: destination,
                                      threshold: 1,
                                      springSource: popSpringSource)

    let dragStream = gestureSource(dragGesture)

    runtime.write(dragStream.onRecognitionState(.ended)
      .velocity(in: containerView)
      .x()
      .threshold(min: -500, max: 500,
                 whenWithin: TossDirection.none,
                 whenBelow: TossDirection.left,
                 whenAbove: TossDirection.right),
                  to: tossDirection)

    let destinationStream = tossDirection.rewrite([
      .none: containerView.bounds.midX,
      .left: -view.bounds.width,
      .right: containerView.bounds.width + view.bounds.width
      ]
    )
    runtime.write(destinationStream, to: attachment.spring.destination)

    let gestureEnabledStream = tossDirection.rewrite([
      .none: true,
      .left: false,
      .right: false
      ]
    )
    runtime.write(gestureEnabledStream, to: propertyOf(dragGesture).isEnabled)
    runtime.write(gestureEnabledStream, to: propertyOf(view).isUserInteractionEnabled)

    let initialVelocityStream = dragStream.onRecognitionState(.ended).velocity(in: containerView).x()
    runtime.write(initialVelocityStream, to: attachment.spring.initialVelocity)

    let translationStream = dragStream
      .translated(from: propertyOf(view).center, in: containerView)
      .x()
    runtime.write(attachment.valueStream.toggled(with: translationStream), to: position)

    let radians = CGFloat(M_PI / 180.0 * 15.0)
    let rotationStream = position
      .offset(by: -containerView.bounds.width / 2)
      .normalized(by: containerView.bounds.width / 2)
      .scaled(by: radians)

    // Previous card
    if let previousCard = previousCard {
      dragGesture.require(toFail: previousCard.dragGesture)
      let nextRotationStream = previousCard.position
        .distance(from: containerView.bounds.width / 2)
        .normalized(by: containerView.bounds.width / 2)
        .max(1)
        .subtracted(from: 1)
        .scaled(by: rotation)
      runtime.write(nextRotationStream.toggled(with: rotationStream),
                    to: propertyOf(view.layer).rotation())
    } else {
      runtime.write(rotationStream, to: propertyOf(view.layer).rotation())
    }
  }

  private let containerView: UIView
  private let dragGesture: UIPanGestureRecognizer
  private let previousCard: TossableStackedCard?
  private let position: ReactiveProperty<CGFloat>
  private let rotation: CGFloat
}

public class SwipeExampleViewController: UIViewController {

  let runtime = MotionRuntime()
  var queue: [TossableStackedCard] = []
  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    (0 ..< 10).forEach { _ in
      dequeueCard().connect(with: runtime)
    }
  }

  var lastRotation: CGFloat = CGFloat(M_PI / 180.0 * 2)
  func dequeueCard() -> TossableStackedCard {
    let rotation = -lastRotation

    let card = UIView(frame: .init(x: 16, y: 16 + 64,
                                    width: view.bounds.size.width - 32,
                                    height: view.bounds.size.height - 32 - 64))
    card.layer.borderWidth = 0.5
    card.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
    card.layer.cornerRadius = 4
    card.layer.shouldRasterize = true
    card.layer.rasterizationScale = UIScreen.main.scale
    card.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(256)) / 256.0,
                                   saturation: 1,
                                   brightness: 1,
                                   alpha: 1)

    let interaction = TossableStackedCard(view: card, containerView: view, previousCard: queue.last, rotation: rotation)

    lastRotation = rotation

    if let last = queue.last {
      view.insertSubview(interaction.view, belowSubview: last.view)
    } else {
      view.addSubview(interaction.view)
    }
    queue.append(interaction)
    return interaction
  }
}
