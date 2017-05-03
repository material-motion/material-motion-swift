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
import MaterialMotion

public final class TransitionSpring2<T: Subtractable> {
  public init(with spring: Spring2<T>, direction: ReactiveProperty<TransitionDirection>) {
    self.spring = spring
    self.direction = direction
  }

  public func enable() {
    guard subscription == nil else { return }
    updateDestination(withDirection: direction.value)

    subscription = direction.subscribeToValue {
      self.updateDestination(withDirection: $0)
    }
  }

  public func disable() {
    subscription?.unsubscribe()
    subscription = nil
  }

  private func updateDestination(withDirection direction: TransitionDirection) {
    if direction == .forward {
      spring.destination = fore
    } else {
      spring.destination = back
    }
  }

  public let spring: Spring2<T>

  public var back: T?
  public var fore: T?

  private let direction: ReactiveProperty<TransitionDirection>
  private var subscription: Subscription?
}

public final class ChangeDirection2 {
  init(_ direction: ReactiveProperty<TransitionDirection>, withVelocityOf gesture: UIPanGestureRecognizer, containerView: UIView) {
    self.direction = direction

    self.stream = Reactive(gesture).events._filter { $0.state == .ended }.velocity(in: containerView)
  }

  public func enable() {
    stream.subscribeToValue {
      var value: CGFloat
      switch self.axis {
      case .x: value = $0.x
      case .y: value = $0.y
      }
      if fabs(value) >= self.minimumVelocity {
        if value < 0 {
          self.direction.value = self.whenNegative
        } else if value > 0 {
          self.direction.value = self.whenPositive
        }
      }
    }
  }

  public var minimumVelocity: CGFloat = 100
  public var whenNegative = TransitionDirection.backward
  public var whenPositive = TransitionDirection.backward

  /**
   The velocity axis to observe.
   */
  public enum Axis {
    /**
     Observes the velocity's x axis.
     */
    case x

    /**
     Observes the velocity's y axis.
     */
    case y
  }

  public var axis: Axis = .y

  private let direction: ReactiveProperty<TransitionDirection>
  private let stream: MotionObservable<CGPoint>
}

class ChangeDirectionOnReleaseExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let targetView = center(createExampleSquareView(), within: view)
    targetView.layer.borderColor = targetView.backgroundColor?.cgColor
    targetView.layer.borderWidth = 1
    targetView.backgroundColor = nil
    view.addSubview(targetView)

    let exampleView = center(createExampleView(), within: view)
    view.addSubview(exampleView)

    let direction = createProperty(withInitialValue: TransitionDirection.backward)

    let tossable = Tossable2(exampleView, containerView: view)

    let transitionSpring = TransitionSpring2(with: tossable.spring, direction: direction)
    transitionSpring.back = CGPoint(x: view.bounds.midX, y: view.bounds.height * 4 / 10)
    transitionSpring.fore = CGPoint(x: view.bounds.midX, y: view.bounds.height * 6 / 10)

    let changeDirection = ChangeDirection2(direction, withVelocityOf: tossable.draggable.gesture._object, containerView: view)
    changeDirection.whenPositive = .forward

    tossable.enable()
    transitionSpring.enable()
    changeDirection.enable()
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Toss the view to change its position.")
  }
}
