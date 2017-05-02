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
import MaterialMotion

public func positionOnTap(inCoordinateSpace coordinateSpace: UIView, withGestureRecognizer gestureRecognizer: UITapGestureRecognizer) -> MotionObservable<CGPoint> {
  let gestureTarget = ReactiveGestureTarget()
  gestureRecognizer.addTarget(gestureTarget, action: #selector(ReactiveGestureTarget.gestureDidChange))
  return gestureTarget.didChange.centroid(in: coordinateSpace)
}

class SetPositionOnTapExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    let tap = UITapGestureRecognizer()
    view.addGestureRecognizer(tap)

    Reactive(tap).events.centroid(in: view).subscribeToValue {
      square.center = $0
    }

    Reactive(tap).state.subscribeToValue { state in
      print(state)
    }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap anywhere to move the view.")
  }
}
