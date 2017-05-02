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

class DirectlyManipulable2 {

  @discardableResult
  class func apply(to view: UIView, relativeTo: UIView) -> [UIGestureRecognizer] {
    let draggable = Draggable2.apply(to: view, relativeTo: relativeTo)
    let rotatable = Rotatable2.apply(to: view, relativeTo: relativeTo)
    let scalable = Scalable2.apply(to: view, relativeTo: relativeTo)

    let stateAggregator = AggregateMotionState()
    stateAggregator.observe(state: draggable.state)
    stateAggregator.observe(state: rotatable.state)
    stateAggregator.observe(state: scalable.state)
    stateAggregator.asStream()._filter { $0 == .active }.subscribeToValue { state in
      guard let gesture = [draggable._object, rotatable._object, scalable._object].max(by: { a, b in a.numberOfTouches < b.numberOfTouches }) else {
        return
      }
      guard gesture.numberOfTouches > 1 else {
        return
      }

      let location = gesture.location(in: view)

      let newAnchorPoint = CGPoint(x: location.x / view.layer.bounds.width, y: location.y / view.layer.bounds.height)
      let newPosition = view.layer.convert(location, to: view.layer.superlayer)

      view.layer.anchorPoint = newAnchorPoint
      view.layer.position = newPosition
    }

    return [draggable._object, rotatable._object, scalable._object]
  }
}

final class AggregateMotionState {

  init(initialState: MotionState = .atRest) {
    state.value = initialState
  }

  /**
   Observe the provided MotionState reactive object.
   */
  func observe<O>(state: O) where O: MotionObservableConvertible, O: AnyObject, O.T == MotionState {
    let identifier = ObjectIdentifier(state)

    state.asStream().dedupe().subscribeToValue { state in
      if state == .active {
        self.activeStates.insert(identifier)
      } else {
        self.activeStates.remove(identifier)
      }
      self.state.value = self.activeStates.count == 0 ? .atRest : .active
    }
  }

  func asStream() -> MotionObservable<MotionState> {
    return state.asStream()
  }

  private let state = createProperty("state", withInitialValue: MotionState.atRest)
  private var activeStates = Set<ObjectIdentifier>()
}

class DirectlyManipulableExampleViewController: ExampleViewController, UIGestureRecognizerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleSquareView(), within: view)
    view.addSubview(square)

    let gestures = DirectlyManipulable2.apply(to: square, relativeTo: view)
    for gesture in gestures {
      gesture.delegate = self
    }
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Pinch, rotate, and drag the view to manipulate it.")
  }
}
