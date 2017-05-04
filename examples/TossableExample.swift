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

public func createTossable(_ view: UIView, containerView: UIView) -> Tossable2<Spring2<CGPoint>> {
  let draggable = Draggable2(view, containerView: containerView)
  let spring = Spring2(for: Reactive(view.layer).positionKeyPath)
  return Tossable2(draggable, spring: spring, containerView: containerView)
}

public class Tossable2<S>: Interaction2, Stateful where S: SpringInteraction, S: Stateful, S.T == CGPoint {
  public init(_ draggable: Draggable2, spring: S, containerView: UIView) {
    self.draggable = draggable
    self.spring = spring
    self.containerView = containerView
  }

  public let draggable: Draggable2
  public let spring: S

  public func enable() {
    guard subscriptions.count == 0 else { return }
    guard let gesture = draggable.gesture else { return }
    var spring = self.spring

    let gestureIsActive = gesture.state == .began || gesture.state == .changed
    if !gestureIsActive {
      spring.enable()
    }

    let reactiveGesture = Reactive(gesture)
    subscriptions.append(contentsOf: [
      reactiveGesture.didBegin { _ in
        spring.disable()
      },
      reactiveGesture.events._filter { $0.state == .ended }.velocity(in: containerView).subscribeToValue { velocity in
        spring.initialVelocity = velocity
        spring.enable()
      }]
    )

    draggable.enable()
  }

  public func disable() {
    draggable.disable()
    spring.disable()

    subscriptions.forEach { $0.unsubscribe() }
    subscriptions.removeAll()
  }

  public var state: MotionObservable<MotionState> {
    return spring.state // TODO: Also include drag state.
  }

  private let containerView: UIView
  private var subscriptions: [Subscription] = []
}

class TossableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleSquareView(), within: view)
    view.addSubview(square)

    let tossable = createTossable(square, containerView: view)
    tossable.spring.destination = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    tossable.enable()
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Use two fingers to rotate the view.")
  }
}
