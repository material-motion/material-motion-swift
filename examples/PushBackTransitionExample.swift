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

    transitionController.directorType = PushBackTransitionDirector.self
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

@available(iOS 9.0, *)
private class PushBackTransitionDirector: TransitionDirector {

  required init() {}

  func willBeginTransition(_ transition: Transition) {
    spring(back: transition.containerView().bounds.height + transition.fore.view.layer.bounds.height / 2,
           fore: transition.containerView().bounds.midY,
           property: transition.runtime.get(transition.fore.view.layer).positionY,
           transition: transition)

    spring(back: 1,
           fore: 0.95,
           property: transition.runtime.get(transition.back.view.layer).scale,
           transition: transition)
  }

  // TODO(featherless): We should be using TransitionSpring, but it doesn't currently support mass
  // and suggested duration.
  private func spring(back: CGFloat, fore: CGFloat, property: ReactiveProperty<CGFloat>, transition: Transition) {
    let from: CGFloat
    let to: CGFloat
    switch transition.direction.value {
    case .forward:
      from = back
      to = fore
    case .backward:
      from = fore
      to = back
    }

    let movement = Spring(to: to, threshold: 1, system: coreAnimation)
    movement.friction.value = 500
    movement.tension.value = 1000
    movement.mass.value = 3
    movement.suggestedDuration.value = 0.5
    transition.runtime.add(movement.stream(withInitialValue: from), to: property)
  }
}
