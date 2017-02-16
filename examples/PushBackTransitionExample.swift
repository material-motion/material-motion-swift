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

  func willBeginTransition(_ transition: Transition, runtime: MotionRuntime) {
    runtime.add(spring(back: transition.containerView().bounds.height + transition.fore.view.layer.bounds.height / 2,
                       fore: transition.containerView().bounds.midY,
                       transition: transition),
                to: runtime.get(transition.fore.view.layer).positionY)

    runtime.add(spring(back: 1, fore: 0.95, transition: transition),
                to: runtime.get(transition.back.view.layer).scale)
  }

  private func spring(back: CGFloat, fore: CGFloat, transition: Transition) -> TransitionSpring<CGFloat> {
    let spring = TransitionSpring(back: back, fore: fore, direction: transition.direction, system: coreAnimation)
    spring.friction.value = 500
    spring.tension.value = 1000
    spring.mass.value = 3
    spring.suggestedDuration.value = 0.5
    return spring
  }
}
