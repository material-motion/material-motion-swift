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

import Foundation
import UIKit

/**
 The possible configurations of a gesturable interaction.
 */
public enum GesturableConfiguration <T: UIGestureRecognizer> {
  /**
   When the interaction is added to a view, the interaction will create a new gesture recognizer and
   register it on the target view.
   */
  case registerNewRecognizerToTargetView

  /**
   When the interaction is added to a view, the interaction will create a new gesture recognizer and
   register it on the given view.
   */
  case registerNewRecognizerTo(UIView)

  /**
   The interaction will make use of the provided gesture recognizer.

   The interaction will not associate this gesture recognizer with any view.
   */
  case withExistingRecognizer(T)
}

/**
 Gesturable is the base type for a gesture-driven interaction.

 This class provides common scaffolding for managing the creation and registration of gesture
 recognizers to a target reactive view.
 */
public class Gesturable<T: UIGestureRecognizer> {
  public let config: GesturableConfiguration<T>

  // Due to a bug in Xcode 8.2.1 we can't use a default argument in our init method, so we provide
  // this convenience initializer instead.
  public convenience init() {
    self.init(.registerNewRecognizerToTargetView)
  }

  /**
   Initializes the interaction with the first gesture recognizer that matches the interaction's T
   type.
   */
  public convenience init<O>(withFirstGestureIn gestures: O) where O: Sequence, O.Iterator.Element == UIGestureRecognizer {
    var first: T? = nil
    for gesture in gestures {
      if let gesture = gesture as? T {
        first = gesture
        break
      }
    }
    if let first = first {
      self.init(.withExistingRecognizer(first))
    } else {
      self.init()
    }
  }

  public init(_ config: GesturableConfiguration<T>) {
    self.config = config

    let initialState: MotionState
    switch self.config {
    case .withExistingRecognizer(let recognizer):
      initialState = (recognizer.state == .began || recognizer.state == .changed) ? .active : .atRest
    default: ()
      initialState = .atRest
    }

    self.aggregateState = AggregateMotionState(initialState: initialState)
  }

  /**
   Returns the gesture recognizer that will be used when this interaction is added to a view.

   This property may change after the interaction has been added to a view depending on the
   interaction's configuration.
   */
  public var nextGestureRecognizer: T {
    if let nextGestureRecognizer = _nextGestureRecognizer {
      return nextGestureRecognizer
    }

    let gestureRecognizer: T

    switch config {
    case .registerNewRecognizerToTargetView:
      gestureRecognizer = T()

    case .registerNewRecognizerTo(let view):
      gestureRecognizer = T()
      view.addGestureRecognizer(gestureRecognizer)

    case .withExistingRecognizer(let existingGestureRecognizer):
      gestureRecognizer = existingGestureRecognizer
    }

    _nextGestureRecognizer = gestureRecognizer
    return gestureRecognizer
  }

  /**
   Prepares and returns the gesture recognizer that should be used to drive this interaction.
   */
  func dequeueGestureRecognizer(withReactiveView reactiveView: ReactiveUIView) -> T {
    let gestureRecognizer = self.nextGestureRecognizer
    _nextGestureRecognizer = nil

    switch config {
    case .registerNewRecognizerToTargetView:
      reactiveView.view.addGestureRecognizer(gestureRecognizer)
    default: ()
    }

    gestureRecognizer.view?.isUserInteractionEnabled = true

    return gestureRecognizer
  }

  /**
   The current state of the drag gesture.
   */
  public var state: MotionObservable<MotionState> {
    return aggregateState.asStream()
  }

  let aggregateState: AggregateMotionState

  private var _nextGestureRecognizer: T?
}
