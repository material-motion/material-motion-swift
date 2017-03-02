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

public class ModalDialogExampleViewController: UIViewController {

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  func didTap() {
    let vc = ModalDialogViewController()
    present(vc, animated: true)
  }

  func tapToDismiss() {
    dismiss(animated: true)
  }
}

class ModalDialogViewController: UIViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    transitionController.transitionType = ModalDialogTransition.self

    modalPresentationStyle = .overCurrentContext
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .blue

    view.layer.cornerRadius = 5
    view.layer.shadowColor = UIColor(white: 0, alpha: 0.4).cgColor
    view.layer.shadowRadius = 5
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = .init(width: 0, height: 2)

    preferredContentSize = .init(width: 200, height: 200)
  }
}

class ModalDialogTransition: SelfDismissingTransition {

  required init() {}

  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [MotionObservable<MotionState>] {
    let size = ctx.fore.preferredContentSize

    if ctx.direction == .forward {
      ctx.fore.view.bounds = CGRect(origin: .zero, size: size)
    }

    let bounds = ctx.containerView().bounds
    let backPositionY = bounds.maxY + size.height * 3 / 4
    let forePositionY = bounds.midY

    let mainThreadReactive: Bool
    let system: SpringToStream<CGFloat>
    if #available(iOS 9.0, *) {
      mainThreadReactive = false
      system = coreAnimation
    } else {
      mainThreadReactive = true
      system = pop
    }
    let spring = TransitionSpring(back: backPositionY,
                                  fore: forePositionY,
                                  direction: ctx.direction,
                                  threshold: 1,
                                  system: system)

    let reactiveForeLayer = runtime.get(ctx.fore.view.layer)

    for gestureRecognizer in ctx.gestureRecognizers {
      switch gestureRecognizer {
      case let pan as UIPanGestureRecognizer:
        let gesture = runtime.get(pan)

        let dragStream = gesture.translated(from: reactiveForeLayer.position).y()
        runtime.add(dragStream, to: reactiveForeLayer.positionY)

        let velocityStream = gesture.velocityOnReleaseStream().y()
        runtime.add(velocityStream, to: spring.initialVelocity)

        let centerY = ctx.containerView().bounds.height / 2.0
        let positionY = reactiveForeLayer.positionY
        let positionDestination: MotionObservable<TransitionContext.Direction> =
          positionY.threshold(centerY).rewrite([.whenBelow: .forward, .whenAbove: .backward])

        runtime.add(velocityStream
          .thresholdRange(min: -100, max: 100)
          // If one of rewrite's target values is a stream, then all the target values must be
          // streams.
          .rewrite([.whenBelow: createProperty(withInitialValue: .forward).asStream(),
                    .whenWithin: positionDestination,
                    .whenAbove: createProperty(withInitialValue: .backward).asStream()]),
                    to: ctx.direction)

        runtime.add(gesture.atRest(), to: spring.enabled)

      default:
        ()
      }
    }

    runtime.add(spring, to: reactiveForeLayer.positionY)

    if mainThreadReactive {
      let rotation = reactiveForeLayer.positionY
        .rewriteRange(start: spring.backwardDestination,
                      end: spring.forwardDestination,
                      destinationStart: CGFloat(Double.pi / 8),
                      destinationEnd: 0)
      runtime.add(rotation, to: reactiveForeLayer.rotation)
    }

    return [spring.state]
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
