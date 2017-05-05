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

class ModalDialogExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  func didTap() {
    let vc = ModalDialogViewController()
    present(vc, animated: true)
  }

  func tapToDismiss() {
    dismiss(animated: true)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap to present a modal dialog.")
  }
}

class ModalDialogViewController: UIViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    transitionController.transitionType = ModalDialogTransition.self
    preferredContentSize = .init(width: 200, height: 200)
    modalPresentationStyle = .overCurrentContext
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .primaryColor

    view.layer.cornerRadius = 5
    view.layer.shadowColor = UIColor(white: 0, alpha: 0.4).cgColor
    view.layer.shadowRadius = 5
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = .init(width: 0, height: 2)
  }
}

class ModalDialogTransition: SelfDismissingTransition {

  required init() {}

  private var tossable: Tossable2<TransitionSpring2<CGPoint>>?
  deinit {
    // TODO: It's important that we tear down any subscriptions after the transition completes or
    // we'll end up having multiple subscriptions hanging around forever.
    // TODO: Perhaps we want Reactive to be able to retrieve all of the subscriptions for a given object?
    tossable?.disable()
  }

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
    let size = ctx.fore.view.frame.size
    let bounds = ctx.containerView().bounds
    let backPosition = CGPoint(x: bounds.midX, y: bounds.maxY + size.height * 3 / 4)
    let forePosition = ctx.fore.view.layer.position

    let transitionSpring = TransitionSpring2(for: Reactive(ctx.fore.view.layer).positionKeyPath,
                                             direction: ctx.direction)
    transitionSpring.destinations = [
      .backward: backPosition,
      .forward: forePosition
    ]
    let tossable = Tossable2(ctx.fore.view, containerView: ctx.containerView(), spring: transitionSpring)

    tossable.draggable.addConstraint { $0.xLocked(to: bounds.midX) }
    tossable.draggable.gesture = ctx.gestureRecognizers.flatMap { $0 as? UIPanGestureRecognizer }.first

    if let gesture = tossable.draggable.gesture {

      let centerY = ctx.containerView().bounds.height / 2.0

      // TODO: Turn this into an interaction.
      Reactive(gesture)
        .events
        ._filter { $0.state == .ended }
        .velocity(in: ctx.containerView())
        .y()
        .thresholdRange(min: -100, max: 100)
        .rewrite([.within: transitionSpring.spring.path.property.y().threshold(centerY).rewrite([.below: .forward,
                                                                                                 .above: .backward])]).subscribeToValue {
          ctx.direction.value = $0
      }

      let changeDirection = ChangeDirection2(ctx.direction, withVelocityOf: gesture, containerView: ctx.containerView())
      changeDirection.whenNegative = .forward
      changeDirection.enable()
    }

    tossable.enable()

    self.tossable = tossable

    print(ctx.fore.view.gestureRecognizers)

    return [tossable.spring]
  }

  static func willPresent(fore: UIViewController, dismisser: ViewControllerDismisser) {
    let tap = UITapGestureRecognizer()
    fore.view.addGestureRecognizer(tap)
    dismisser.dismissWhenGestureRecognizerBegins(tap)
    let pan = UIPanGestureRecognizer()
    fore.view.addGestureRecognizer(pan)
    dismisser.dismissWhenGestureRecognizerBegins(pan)
  }
}
