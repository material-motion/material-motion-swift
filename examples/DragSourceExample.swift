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

  func willBeginTransition(_ transition: Transition, runtime: MotionRuntime) {
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

    let tween = Tween(duration: 0.35, values: [from, to], system: coreAnimation)
    runtime.add(tween, to: runtime.get(transition.fore.view.layer).positionY)
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

  var runtime: MotionRuntime!
  public override func viewDidLoad() {
    super.viewDidLoad()

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = UIColor(colorLiteralRed: 0.98039215686275, green: 0.98039215686275, blue: 0.98039215686275, alpha: 1)

    var center = view.center
    center.x -= 64
    center.y -= 64

    let circle1 = UIView(frame: .init(x: center.x + 100, y: center.y - 100, width: 64, height: 64))
    circle1.backgroundColor = .white
    circle1.layer.cornerRadius = 32

    let circle2 = UIView(frame: .init(x: center.x + 100 + 22.62741699796952, y: center.y - 100 - 22.62741699796952, width: 64, height: 64))
    circle2.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.41960784313725, blue: 0.66274509803922, alpha: 1)
    circle2.layer.cornerRadius = 32

    let circle3 = UIView(frame: .init(x: center.x + 100 + 22.62741699796952 * 2, y: center.y - 100 - 22.62741699796952 * 2, width: 64, height: 64))
    circle3.backgroundColor = UIColor(colorLiteralRed: 0.84705882352941, green: 0, blue: 0.37254901960784, alpha: 0.7)
    circle3.layer.cornerRadius = 32

    view.addSubview(circle1)
    view.addSubview(circle2)
    view.addSubview(circle3)

  }
}
