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

public class DirectlyManipulableExampleViewController: UIViewController, UIGestureRecognizerDelegate {

  let runtime = MotionRuntime()
  var subscription: Subscription!
  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let square = UIView(frame: .init(x: 100, y: 300, width: 128, height: 128))
    square.backgroundColor = .red
    view.addSubview(square)

    let pan = UIPanGestureRecognizer()
    let rotate = UIRotationGestureRecognizer()
    let scale = UIPinchGestureRecognizer()
    [pan, rotate, scale].forEach { $0.delegate = self }

    DirectlyManipulable(view: square,
                        containerView: view,
                        panGestureRecognizer: pan,
                        rotationGestureRecognizer: rotate,
                        scaleGestureRecognizer: scale)
      .connect(with: runtime)
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
