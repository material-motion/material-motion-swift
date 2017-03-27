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

    view.backgroundColor = .primaryColor

    let pan = UIPanGestureRecognizer()
    transitionController.dismisser.dismissWhenGestureRecognizerBegins(pan)
    view.addGestureRecognizer(pan)
  }
}

private class PushBackTransition: Transition {

  required init() {}

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
    let firstPan = ctx.gestureRecognizers.first { $0 is UIPanGestureRecognizer }
    let draggable: Draggable
    if let firstPan = firstPan as? UIPanGestureRecognizer {
      draggable = Draggable(.withExistingRecognizer(firstPan))
    } else {
      draggable = Draggable()
    }

    let gesture = runtime.get(draggable.nextGestureRecognizer)
    runtime.connect(gesture
      .velocityOnReleaseStream()
      .y()
      .thresholdRange(min: -100, max: 100)
      .rewrite([.below: .forward,
                .within: ctx.direction.value,
                .above: .backward]),
                to: ctx.direction)

    let bounds = ctx.containerView().bounds
    let backPosition = CGPoint(x: bounds.midX, y: bounds.maxY + ctx.fore.view.bounds.height / 2)
    let forePosition = CGPoint(x: bounds.midX, y: bounds.midY)
    let movement = TransitionSpring(back: backPosition,
                                    fore: forePosition,
                                    direction: ctx.direction)
    let scaleSpring = TransitionSpring<CGFloat>(back: 1, fore: 0.95, direction: ctx.direction)

    let scale = runtime.get(ctx.back.view.layer).scale
    runtime.connect(runtime.get(ctx.fore.view.layer).position.y()
      // The position's final value gets written to by Core Animation when the gesture ends and the
      // movement spring engages. Because we're connecting position to the scale here, this would
      // also cause scale to jump to its destination as well (without animating, unfortunately).
      // To ensure that we don't receive this information, we valve the stream based on the gesture
      // activity and ensure that we register this valve *before* committing Tossable to the
      // runtime.
      .valve(openWhenTrue: gesture.active())
      .rewriteRange(start: movement.backwardDestination.y,
                    end: movement.forwardDestination.y,
                    destinationStart: scaleSpring.backwardDestination,
                    destinationEnd: scaleSpring.forwardDestination),
                to: scale)

    let tossable = Tossable(spring: movement, draggable: draggable)
    runtime.add(tossable, to: ctx.fore.view) { $0.xLocked(to: ctx.fore.view.layer.position.x) }

    runtime.toggle(scaleSpring, inReactionTo: draggable)
    runtime.add(scaleSpring, to: scale)

    return [tossable.spring, scaleSpring, gesture]
  }
}
