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
public class InteractivePushBackTransitionExampleViewController: UIViewController {

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

    let pan = UIPanGestureRecognizer()
    transitionController.dismisser.dismissWhenGestureRecognizerBegins(pan)
    view.addGestureRecognizer(pan)
  }
}

@available(iOS 9.0, *)
private class PushBackTransition: Transition {

  required init() {}

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful] {
    let foreLayer = runtime.get(ctx.fore.view.layer)

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
      .rewrite([.whenBelow: .forward,
                .whenWithin: ctx.direction.value,
                .whenAbove: .backward]),
                to: ctx.direction)

    let bounds = ctx.containerView().bounds
    let backPosition = CGPoint(x: bounds.midX, y: bounds.maxY + ctx.fore.view.bounds.height / 2)
    let forePosition = CGPoint(x: bounds.midX, y: bounds.midY)
    let movement = spring(back: backPosition,
                          fore: forePosition,
                          threshold: 1,
                          ctx: ctx)
    let scaleSpring = spring(back: CGFloat(1), fore: CGFloat(0.95), threshold: 0.005, ctx: ctx)

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
    runtime.add(tossable, to: ctx.fore.view)
 
    runtime.enable(scaleSpring, whenAtRest: gesture)
    runtime.add(scaleSpring, to: scale)

    return [tossable.spring, scaleSpring, gesture]
  }

  private func spring<T>(back: T, fore: T, threshold: CGFloat, ctx: TransitionContext) -> TransitionSpring<T> where T: Subtractable, T: Zeroable, T: Equatable {
    let spring = TransitionSpring(back: back, fore: fore, direction: ctx.direction, threshold: threshold, system: coreAnimation)
    spring.friction.value = 500
    spring.tension.value = 1000
    spring.mass.value = 3
    spring.suggestedDuration.value = 0.5
    return spring
  }
}
