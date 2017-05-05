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

func prepareGesture<GestureType: UIGestureRecognizer>(relativeTo: UIView, withGestureRecognizer existingGesture: GestureType?) -> GestureType {
  let gesture: GestureType
  if let existingGesture = existingGesture {
    gesture = existingGesture
  } else {
    gesture = GestureType()
    relativeTo.addGestureRecognizer(gesture)
  }
  return gesture
}

public class Draggable2: Interaction2, Stateful {

  public convenience init(_ view: UIView,
                          containerView: UIView,
                          withGestureRecognizer existingGesture: UIPanGestureRecognizer) {
    self.init(Reactive(view.layer).position,
              containerView: containerView,
              withGestureRecognizer: existingGesture)
  }

  public convenience init<O>(_ view: UIView,
                          containerView: UIView,
                          withFirstGestureIn gestures: O) where O: Sequence, O.Iterator.Element == UIGestureRecognizer {
    var first: UIPanGestureRecognizer? = nil
    for gesture in gestures {
      if let gesture = gesture as? UIPanGestureRecognizer {
        first = gesture
        break
      }
    }
    self.init(Reactive(view.layer).position, containerView: containerView, withGestureRecognizer: first)
  }

  public convenience init(_ view: UIView, containerView: UIView) {
    let gesture = UIPanGestureRecognizer()
    containerView.addGestureRecognizer(gesture)

    self.init(Reactive(view.layer).position, containerView: containerView, withGestureRecognizer: gesture)
  }

  private init(_ property: ReactiveProperty<CGPoint>, containerView: UIView, withGestureRecognizer gesture: UIPanGestureRecognizer?) {
    self.containerView = containerView
    self.property = property
    self.gesture = gesture
  }

  public func enable() {
    guard subscriptions.isEmpty else { return }

    let gestureRecognizer: UIPanGestureRecognizer
    if let existingGestureRecognizer = self.gesture {
      gestureRecognizer = existingGestureRecognizer
    } else {
      gestureRecognizer = UIPanGestureRecognizer()
      self.containerView.addGestureRecognizer(gestureRecognizer)
    }

    let property = self.property
    let state = _state

    subscriptions.append(contentsOf: [
      constraints.reduce(Reactive(gestureRecognizer).events.translation(addedTo: property, in: containerView)) { $1($0) }.subscribeToValue {
        property.value = $0
      },
      Reactive(gestureRecognizer).state.subscribeToValue {
        state.value = $0
      }
    ])
  }

  public func disable() {
    subscriptions.forEach { $0.unsubscribe() }
    subscriptions.removeAll()
    _state.value = .atRest
  }

  public func addConstraint(_ constraint: @escaping (MotionObservable<CGPoint>) -> MotionObservable<CGPoint>) {
    constraints.append(constraint)
  }
  public private(set) var constraints: [(MotionObservable<CGPoint>) -> MotionObservable<CGPoint>] = []

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }
  private let _state = createProperty(withInitialValue: MotionState.atRest)

  @discardableResult
  public class func apply(to view: UIView, containerView: UIView, withGestureRecognizer existingGesture: UIPanGestureRecognizer) -> Draggable2 {
    let draggable = Draggable2(view, containerView: containerView, withGestureRecognizer: existingGesture)
    draggable.enable()
    return draggable
  }

  private let property: ReactiveProperty<CGPoint>
  private var subscriptions: [Subscription] = []
  private let containerView: UIView

  public var gesture: UIPanGestureRecognizer?
}

class DraggableExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    let draggable = Draggable2(square, containerView: view)
    draggable.enable()
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Drag the view to move it.")
  }
}
