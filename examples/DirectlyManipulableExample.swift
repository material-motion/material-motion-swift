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
    let draggable = Draggable2(view, containerView: relativeTo)
    let rotatable = Rotatable2.apply(to: view, relativeTo: relativeTo)
    let scalable = Scalable2.apply(to: view, relativeTo: relativeTo)

    AdjustsAnchorPoint2.apply(to: view, gestures: [draggable.gesture._object, rotatable._object, scalable._object])

    return [draggable.gesture._object, rotatable._object, scalable._object]
  }
}

class AdjustsAnchorPoint2 {

  @discardableResult
  class func apply(to view: UIView, gestures: [UIGestureRecognizer]) {
    let originalAnchorPoint = view.layer.anchorPoint

    let weakGestures = NSHashTable<UIGestureRecognizer>.weakObjects()

    let stateAggregator = AggregateMotionState()
    for gesture in gestures {
      stateAggregator.observe(state: Reactive(gesture).state)
      weakGestures.add(gesture)
    }

    Reactive(view).subscriptions.append(stateAggregator.asStream().dedupe().subscribeToValue { [weak view] state in
      guard let view = view else { return }

      guard let gesture = weakGestures.allObjects.max(by: { a, b in
        a.numberOfTouches < b.numberOfTouches
      }) else { return }

      let reactiveLayer = Reactive(view.layer)

      let newAnchorPoint: CGPoint
      let newPosition: CGPoint
      if state == .active {
        let location = gesture.location(in: view)

        newAnchorPoint = CGPoint(x: location.x / reactiveLayer.width.value,
                                 y: location.y / reactiveLayer.height.value)
        newPosition = view.layer.convert(location, to: view.layer.superlayer)

      } else {
        newAnchorPoint = originalAnchorPoint
        let restoredPosition = CGPoint(x: originalAnchorPoint.x * reactiveLayer.width.value,
                                       y: originalAnchorPoint.y * reactiveLayer.height.value)
        newPosition = view.layer.convert(restoredPosition, to: view.layer.superlayer)
      }

      reactiveLayer.anchorPoint.value = newAnchorPoint
      reactiveLayer.position.value = newPosition
    })
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
