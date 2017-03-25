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

/**
 A stateful type can either be active or at rest.
 */
public protocol Stateful {
  /**
   An observable representing this type's current state.
   */
  var state: MotionObservable<MotionState> { get }
}

/**
 The possible states that an interaction may be in.
 */
public enum MotionState {
  /**
   The interaction is at rest.
   */
  case atRest

  /**
   The interaction is currently taking effect.
   */
  case active
}

/**
 Aggregates one or more MotionState streams into a single stream.

 If any observed stream is active, then the aggregate is active. Otherwise, the aggregate is at
 rest.
 */
final class AggregateMotionState {

  init(initialState: MotionState = .atRest) {
    state.value = initialState
  }

  /**
   Observe the provided MotionState reactive object.
   */
  func observe<O>(state: O, withRuntime runtime: MotionRuntime) where O: MotionObservableConvertible, O: AnyObject, O.T == MotionState {
    let identifier = ObjectIdentifier(state)
    runtime.connect(state.asStream().dedupe(), to: ReactiveProperty("Aggregate state", initialValue: .atRest) { state in
      if state == .active {
        self.activeStates.insert(identifier)
      } else {
        self.activeStates.remove(identifier)
      }
      self.state.value = self.activeStates.count == 0 ? .atRest : .active
    })
  }

  func asStream() -> MotionObservable<MotionState> {
    return state.asStream()
  }

  private let state = createProperty("state", withInitialValue: MotionState.atRest)
  private var activeStates = Set<ObjectIdentifier>()
}
