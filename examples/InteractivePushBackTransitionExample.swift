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
//
//    scrollView = UIScrollView(frame: view.bounds)
//    scrollView.contentSize = .init(width: view.bounds.width, height: view.bounds.height * 10)
//    view.addSubview(scrollView)

    let pan = UIPanGestureRecognizer()
//    pan.delegate = transitionController.topEdgeDismisserDelegate(for: scrollView)
    transitionController.dismissWhenGestureRecognizerBegins(pan)
//    scrollView.panGestureRecognizer.require(toFail: pan)
    view.addGestureRecognizer(pan)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

private class PushBackTransition: Transition {

  required init() {}

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
    let bounds = ctx.containerView().bounds

    let transitionSpring = TransitionSpring2(for: Reactive(ctx.fore.view.layer).positionKeyPath,
                                             direction: ctx.direction)
    transitionSpring.destinations = [
      .backward: CGPoint(x: bounds.midX, y: bounds.maxY + ctx.fore.view.bounds.height / 2),
      .forward: CGPoint(x: bounds.midX, y: bounds.midY)
    ]
    let tossable = Tossable2(ctx.fore.view, containerView: ctx.containerView(), spring: transitionSpring)

    tossable.draggable.gesture = ctx.gestureRecognizers.flatMap { $0 as? UIPanGestureRecognizer }.first

    if let gesture = tossable.draggable.gesture {
      let changeDirection = ChangeDirection2(ctx.direction, withVelocityOf: gesture, containerView: ctx.containerView())
      changeDirection.whenNegative = .forward
      changeDirection.enable()
    }

    tossable.enable()

    tossable.draggable.state.subscribeToValue {
      print("Draggable: \($0)")
    }
    tossable.spring.state.subscribeToValue {
      print("Spring: \($0)")
    }
    tossable.state.subscribeToValue {
      print("Tossable: \($0)")
    }

    return [tossable]
  }
}
