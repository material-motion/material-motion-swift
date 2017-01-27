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

// This example demonstrates how to connect a drag source to a property on a view.

class ExampleTransitionDirector: TransitionDirector {
  required init() {}

  func willBeginTransition(_ transition: Transition) {
    let backPositionY = transition.containerView().bounds.height * 1.5
    let forePositionY = transition.containerView().bounds.midY

    let from: CGFloat
    let to: CGFloat
    switch transition.direction.value {
    case .forward:
      from = backPositionY
      to = forePositionY
    case .backward:
      from = forePositionY
      to = backPositionY
    }

    let tween = Tween<CGFloat>(duration: 0.35, values: [from, to])
    let fade$ = coreAnimation(tween)
    transition.runtime.write(fade$, to: propertyOf(transition.fore.view.layer).positionY())
  }
}

@available(iOS 9.0, *)
public class DragSourceExampleViewController: UIViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTap))
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func didTap() {
    let vc = UIViewController()
    vc.view.backgroundColor = .red
    let tap = UITapGestureRecognizer()
    tap.addTarget(self, action: #selector(tapToDismiss))
    vc.view.addGestureRecognizer(tap)
    vc.transitionController.directorType = ExampleTransitionDirector.self
    present(vc, animated: true)
  }

  func tapToDismiss() {
    dismiss(animated: true)
  }

  let runtime = MotionRuntime()
  var subscription: Subscription!
  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    var center = view.center
    center.x -= 32
    center.y -= 32

    let square = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    square.backgroundColor = .red
    view.addSubview(square)

    let square2 = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    square2.backgroundColor = .orange
    view.addSubview(square2)

    let circle = UIView(frame: .init(x: center.x, y: center.y, width: 64, height: 64))
    circle.backgroundColor = .blue
    circle.layer.cornerRadius = circle.bounds.width / 2
    view.addSubview(circle)

    let tossable = TossableAndAttachWithSpring(position: propertyOf(square).center,
                                               to: propertyOf(circle).center,
                                               containerView: view,
                                               springSystem: pop)
    tossable.connect(with: runtime)

    let spring = Spring(to: tossable.spring.destination,
                        initialValue: propertyOf(square2.layer).position(),
                        threshold: 1,
                        system: coreAnimation)
    runtime.write(spring.valueStream, to: propertyOf(square2.layer).position())

    Tap(sets: tossable.spring.destination, containerView: view).connect(with: runtime)
  }
}
