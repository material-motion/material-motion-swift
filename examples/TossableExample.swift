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

public class Tossable2 {
  public init(_ view: UIView, containerView: UIView) {
    self.draggable = Draggable2(view, containerView: containerView)
    self.spring = Spring2(for: Reactive(view.layer).positionKeyPath)
    self.containerView = containerView
  }

  public let draggable: Draggable2
  public let spring: Spring2<CGPoint>

  public func enable() {
    guard subscriptions.count == 0 else { return }
    let spring = self.spring

    subscriptions.append(contentsOf: [
      draggable.gesture.didBegin { _ in
        spring.stop()
      },
      draggable.gesture.events._filter { $0.state == .ended }.velocity(in: containerView).subscribeToValue { velocity in
        spring.initialVelocity = velocity
        spring.start()
      }]
    )

    draggable.enable()
    spring.start()
  }

  public func disable() {
    draggable.disable()
    spring.stop()

    subscriptions.forEach { $0.unsubscribe() }
    subscriptions.removeAll()
  }


  private let containerView: UIView
  private var subscriptions: [Subscription] = []
}

class TossableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleSquareView(), within: view)
    view.addSubview(square)

    let tossable = Tossable2(square, containerView: view)
    tossable.spring.destination = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    tossable.enable()
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Use two fingers to rotate the view.")
  }
}
