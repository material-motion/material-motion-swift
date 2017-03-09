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

public class DraggableConstraintExampleViewController: UIViewController {

  var runtime: MotionRuntime!

  public override func viewDidLoad() {
    super.viewDidLoad()

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = .white

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    runtime.add(Draggable(), to: square) { $0.xLocked(to: square.layer.position.x) }
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    title = type(of: self).catalogBreadcrumbs().last
    navigationItem.prompt = "Drag the blue square to move it on the y axis."
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
