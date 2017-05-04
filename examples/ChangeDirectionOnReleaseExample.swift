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

public final class StateMachine<T: Hashable, U>: Interaction2 {
  init<O>(stream: O, map: [T: U]? = nil, didChange: @escaping (U) -> Void) where O: MotionObservableConvertible, O.T == T {
    self.stream = stream.asStream()
    if let map = map {
      self.map = map
    }
    self.didChange = didChange
  }
  public var map: [T: U] = [:]

  public func enable() {
    guard subscription == nil else { return }

    let didChange = self.didChange
    subscription = stream.rewrite(map).subscribeToValue {
      didChange($0)
    }
  }

  public func disable() {
    subscription?.unsubscribe()
    subscription = nil
  }

  private let stream: MotionObservable<T>
  private let didChange: (U) -> Void
  private var subscription: Subscription?
}

public final class TransitionSpring2<T: Subtractable>: SpringInteraction, Stateful {
  public init(for path: CoreAnimationKeyPath<T>, direction: ReactiveProperty<TransitionDirection>) {
    let spring = Spring2(for: path)
    self.spring = spring
    self.direction = direction

    self.stateMachine = StateMachine(stream: direction, didChange: {
      spring.destination = $0
    })
  }

  public func enable() {
    guard subscription == nil else { return }

    let spring = self.spring

    if direction.value == .forward, let back = stateMachine.map[.backward] {
      spring.path.property.value = back
    } else if direction.value == .backward, let fore = stateMachine.map[.forward] {
      spring.path.property.value = fore
    }

    stateMachine.enable()

    spring.enable()
  }

  public func disable() {
    spring.disable()
    stateMachine.disable()
    subscription?.unsubscribe()
    subscription = nil
  }

  public var initialVelocity: T? {
    get { return spring.initialVelocity }
    set { spring.initialVelocity = newValue }
  }

  public var destination: T? {
    get { return spring.destination }
    set { spring.destination = newValue }
  }

  public var state: MotionObservable<MotionState> {
    return spring.state
  }

  public var destinations: [TransitionDirection: T] {
    get { return stateMachine.map }
    set { stateMachine.map = newValue }
  }
  public let spring: Spring2<T>
  private let stateMachine: StateMachine<TransitionDirection, T>

  private let direction: ReactiveProperty<TransitionDirection>
  private var subscription: Subscription?
}

public final class ChangeDirection2: Interaction2 {
  init(_ direction: ReactiveProperty<TransitionDirection>, withVelocityOf gesture: UIPanGestureRecognizer, containerView: UIView) {
    self.direction = direction

    self.stream = Reactive(gesture).events._filter { $0.state == .ended }.velocity(in: containerView)
  }

  public func enable() {
    let axis = self.axis
    let minimumVelocity = self.minimumVelocity
    let whenNegative = self.whenNegative
    let whenPositive = self.whenPositive
    let direction = self.direction

    subscription = stream.subscribeToValue {
      var value: CGFloat
      switch axis {
      case .x: value = $0.x
      case .y: value = $0.y
      }
      if fabs(value) >= minimumVelocity {
        if value < 0 {
          direction.value = whenNegative
        } else if value > 0 {
          direction.value = whenPositive
        }
      }
    }
  }

  public func disable() {
    subscription?.unsubscribe()
    subscription = nil
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
  private var subscription: Subscription?
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

    let transitionSpring = TransitionSpring2(for: Reactive(exampleView.layer).positionKeyPath,
                                             direction: direction)
    transitionSpring.destinations = [
      .backward: CGPoint(x: view.bounds.midX, y: view.bounds.height * 4 / 10),
      .forward: CGPoint(x: view.bounds.midX, y: view.bounds.height * 6 / 10)
    ]

    let tossable = createTossable(exampleView, containerView: view)

    transitionSpring.enable()

    tossable.enable()

    let changeDirection = ChangeDirection2(direction,
                                           withVelocityOf: tossable.draggable.gesture!,
                                           containerView: view)
    changeDirection.whenPositive = .forward
    changeDirection.enable()

  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Toss the view to change its position.")
  }
}
