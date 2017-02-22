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

    transitionController.directorType = PushBackTransitionDirector.self
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
private class PushBackTransitionDirector: TransitionDirector {

  required init() {}

  func willBeginTransition(_ transition: Transition, runtime: MotionRuntime) {
    let foreLayer = runtime.get(transition.fore.view.layer)

    let movement = spring(back: transition.containerView().bounds.height + transition.fore.view.layer.bounds.height / 2,
                          fore: transition.containerView().bounds.midY,
                          threshold: 1,
                          transition: transition)

    let scale = spring(back: 1, fore: 0.95, threshold: 0.005, transition: transition)

    for gestureRecognizer in transition.gestureRecognizers {
      switch gestureRecognizer {
      case let pan as UIPanGestureRecognizer:
        let gesture = runtime.get(pan)

        let dragStream = gesture.translated(from: foreLayer.position).y().lowerBound(foreLayer.layer.bounds.height / 2)
        runtime.add(dragStream, to: foreLayer.positionY)

        let scaleStream = dragStream.mapRange(start: movement.backwardDestination,
                                              end: movement.forwardDestination,
                                              destinationStart: scale.backwardDestination,
                                              destinationEnd: scale.forwardDestination)
        runtime.add(scaleStream, to: runtime.get(transition.back.view.layer).scale)

        let velocityStream = gesture.velocityOnReleaseStream().y()
        runtime.add(velocityStream, to: movement.initialVelocity)

        runtime.add(velocityStream
          .thresholdRange(min: -100, max: 100)
          .rewrite([.whenBelow: .forward,
                    .whenWithin: transition.direction.value,
                    .whenAbove: .backward]),
                    to: transition.direction)

        runtime.add(gesture.atRest(), to: movement.enabled)
        runtime.add(gesture.atRest(), to: scale.enabled)

      default:
        ()
      }
    }

    runtime.add(movement, to: foreLayer.positionY)
    runtime.add(scale, to: runtime.get(transition.back.view.layer).scale)

    transition.terminateWhenAllAtRest([movement.state.asStream(), scale.state.asStream()])
  }

  private func spring(back: CGFloat, fore: CGFloat, threshold: CGFloat, transition: Transition) -> TransitionSpring<CGFloat> {
    let spring = TransitionSpring(back: back, fore: fore, direction: transition.direction, threshold: threshold, system: coreAnimation)
    spring.friction.value = 500
    spring.tension.value = 1000
    spring.mass.value = 3
    spring.suggestedDuration.value = 0.5
    return spring
  }
}
