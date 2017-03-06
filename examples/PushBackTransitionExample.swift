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
import MaterialMotionStreams

@available(iOS 9.0, *)
public class PushBackTransitionExampleViewController: UIViewController {

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  func didTap() {
    let vc = ModalViewController()
    present(vc, animated: true)
  }
}

@available(iOS 9.0, *)
private class ModalViewController: UIViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    transitionController.transitionType = PushBackTransition.self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .blue

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  func didTap() {
    dismiss(animated: true)
  }
}

public enum DefaultKey {
  case friction
  case tension
  case mass
  case suggestedDuration
}

public enum LayerProperty {
  case positionY
  case scale
}

public class StateMachine<State: Hashable>: CoordinatingInteraction, StatefulInteraction {
  init(runtime: MotionRuntime) {
    self.runtime = runtime
  }

  public var defaults: [DefaultKey: CGFloat]?

  subscript(layer: CALayer) -> [State: [LayerProperty: Any]]? {
    get {
      return layerStates[layer]
    }
    set {
      layerStates[layer] = newValue
    }
  }

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }

  public func add(withRuntime runtime: MotionRuntime) {

  }

  private var layerStates: [CALayer: [State: [LayerProperty: Any]]] = [:]
  private let runtime: MotionRuntime

  private let _state = createProperty("StateMachine._state", withInitialValue: MotionState.atRest)
}

@available(iOS 9.0, *)
private class PushBackTransition: Transition {

  required init() {}

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [StatefulInteraction] {
    let stateMachine = StateMachine<TransitionContext.Direction>(runtime: runtime)

    stateMachine.defaults = [
      .friction: 500,
      .tension: 1000,
      .mass: 3,
      .suggestedDuration: 0.5,
    ]

    stateMachine[ctx.fore.view.layer] = [
      .backward: [
        .positionY: ctx.containerView().bounds.height + ctx.fore.view.layer.bounds.height / 2,
        .scale: 1
      ],
      .forward: [
        .positionY: ctx.containerView().bounds.midY,
        .scale: 0.95
      ]
    ]

    runtime.add(stateMachine)

    return [stateMachine]
  }
}
