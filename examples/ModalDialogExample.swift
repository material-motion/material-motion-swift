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

    transitionController.directorType = ModalDialogTransitionDirector.self

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

class ModalDialogTransitionDirector: SelfDismissingTransitionDirector {

  required init() {}

  func willBeginTransition(_ transition: Transition) {
    let size = transition.fore.preferredContentSize

    if transition.direction.read() == .forward {
      transition.fore.view.bounds = CGRect(origin: .zero, size: size)
    }

    let bounds = transition.containerView().bounds
    let backPositionY = bounds.maxY + size.height / 2
    let forePositionY = bounds.midY

    var spring: TransitionSpring<CGFloat>!

    if #available(iOS 9.0, *) {
      spring = TransitionSpring(property: propertyOf(transition.fore.view.layer).positionY(),
                                back: backPositionY,
                                fore: forePositionY,
                                direction: transition.direction,
                                springSource: coreAnimationSpringSource)
    } else {
      // Fallback on earlier versions
    }

    for gestureRecognizer in transition.gestureRecognizers {
      switch gestureRecognizer {
      case let pan as UIPanGestureRecognizer:
        let dragStream = gestureSource(pan).translated(from: propertyOf(transition.fore.view.layer).position(),
                                                       in: transition.containerView()).y()
        spring.valueStream = spring.valueStream.toggled(with: dragStream)
        let velocityStream = gestureSource(pan).onRecognitionState(.ended).velocity(in: transition.containerView()).y()
        transition.runtime.write(velocityStream, to: spring.initialVelocity)
      default:
        ()
      }
    }

    spring.connect(with: transition.runtime)
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
