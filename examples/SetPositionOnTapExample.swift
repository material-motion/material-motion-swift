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

public final class SetPositionOnTap2: Interaction2, Stateful {
  init(_ target: ReactiveProperty<CGPoint>, containerView: UIView, withGestureRecognizer existingGesture: UITapGestureRecognizer) {
    self.target = target
    self.containerView = containerView
    self.gestureRecognizer = existingGesture
  }

  public func enable() {
    guard subscriptions.isEmpty else { return }

    let gestureRecognizer: UITapGestureRecognizer
    if let existingGestureRecognizer = self.gestureRecognizer {
      gestureRecognizer = existingGestureRecognizer
    } else {
      gestureRecognizer = UITapGestureRecognizer()
      self.containerView.addGestureRecognizer(gestureRecognizer)
    }

    let target = self.target
    let containerView = self.containerView
    let state = _state

    subscriptions.append(contentsOf: [
      Reactive(gestureRecognizer).didRecognize.subscribeToValue { [weak containerView] in
        guard let containerView = containerView else { return }
        target.value = $0.location(in: containerView)
      },
      Reactive(gestureRecognizer).state.subscribeToValue {
        state.value = $0
      }
      ]
    )
  }

  public func disable() {
    subscriptions.forEach { $0.unsubscribe() }
    subscriptions.removeAll()
    _state.value = .atRest
  }

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }
  private let _state = createProperty(withInitialValue: MotionState.atRest)

  private let target: ReactiveProperty<CGPoint>
  private let containerView: UIView
  private var subscriptions: [Subscription] = []

  public var gestureRecognizer: UITapGestureRecognizer?
}

class SetPositionOnTapExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    let tap = UITapGestureRecognizer()
    view.addGestureRecognizer(tap)

    let setPosition = SetPositionOnTap2(Reactive(square.layer).position,
                                        containerView: view,
                                        withGestureRecognizer: tap)
    setPosition.enable()

    setPosition.state.subscribeToValue { state in
      print(state)
    }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap anywhere to move the view.")
  }
}
