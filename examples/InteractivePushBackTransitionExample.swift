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
import MaterialMotion

class InteractivePushBackTransitionExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  func didTap() {
    let vc = ModalViewController()
    present(vc, animated: true)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap to present a modal transition.")
  }
}

private class ModalViewController: UIViewController, UIGestureRecognizerDelegate {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    transitionController.transitionType = PushBackTransition.self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var scrollView: UIScrollView!
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .primaryColor

    scrollView = UIScrollView(frame: view.bounds)
    scrollView.contentSize = .init(width: view.bounds.width, height: view.bounds.height * 10)
    view.addSubview(scrollView)

    let pan = UIPanGestureRecognizer()
    pan.delegate = transitionController.topEdgeDismisserDelegate(for: scrollView)
    transitionController.dismissWhenGestureRecognizerBegins(pan)
    scrollView.panGestureRecognizer.require(toFail: pan)
    view.addGestureRecognizer(pan)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

private class PushBackTransition: Transition {

  required init() {}

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
    let draggable = Draggable2(ctx.fore.view, containerView: ctx.containerView(), withFirstGestureIn: ctx.gestureRecognizers)

    let changeDirection = ChangeDirection2(ctx.direction,
                                           withVelocityOf: draggable.gesture!,
                                           containerView: ctx.containerView())
    changeDirection.enable()

    let spring = Spring2(for: Reactive(ctx.fore.view.layer).positionKeyPath)

    // TODO: This should be initializable without having to create a spring or draggable instance.
    // TODO: We should be able to change draggable's gesture recognizer before it starts.
    let tossable = Tossable2(draggable, spring: spring, containerView: ctx.containerView())

    let bounds = ctx.containerView().bounds

    // TODO: Rename this to StateMachine and allow the client to pass a map of rewrite values.

    let transitionSpring = TransitionSpring2(with: tossable.spring, direction: ctx.direction)
    transitionSpring.back = CGPoint(x: bounds.midX, y: bounds.maxY + ctx.fore.view.bounds.height / 2)
    transitionSpring.fore = CGPoint(x: bounds.midX, y: bounds.midY)
    transitionSpring.enable()

    return [tossable]
  }
}
