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
import IndefiniteObservable

/**
 A MotionRuntime writes the output of streams to properties and observes their overall state.
 */
public class MotionRuntime {

  /**
   The aggregate state of all registered streams.

   If any stream is active, the aggregate state is active. Otherwise, the aggregate state is at
   rest.
   */
  public let state = createProperty(withInitialValue: MotionState.atRest)

  /** Creates a motion runtime instance. */
  public init() {
  }

  /** Subscribes to the stream, writes its output to the given property, and observes its state. */
  public func write<O: ExtendableMotionObservable, T>(_ stream: O, to property: ReactiveProperty<T>) where O.T == T {
    let token = NSUUID().uuidString
    subscriptions.append(stream.subscribe(next: property.write, state: { [weak self] state in
      property.state(state)

      guard let strongSelf = self else { return }
      strongSelf.stateDidChange(state, for: token)

    }, coreAnimation: property.coreAnimation))
  }

  /**
   Subscribes to the stream, writes its output to the given writable, and observes its state.

   Will not forward state/coreAnimation invocations along.
   */
  public func write<O: ExtendableMotionObservable, P: Writable>(_ stream: O, to writable: P) where O.T == P.T {
    let token = NSUUID().uuidString
    subscriptions.append(stream.subscribe(next: writable.write, state: { [weak self] state in
      guard let strongSelf = self else { return }
      strongSelf.stateDidChange(state, for: token)

    }, coreAnimation: { _ in
      assertionFailure("Writing to a value that does not support Core Animation.")
    }))
  }

  private func stateDidChange(_ state: MotionState, for token: String) {
    if state == .active {
      activeSubscriptions.insert(token)
    } else {
      activeSubscriptions.remove(token)
    }

    let oldState = self.state.read()
    let newState: MotionState = activeSubscriptions.count > 0 ? .active : .atRest
    if oldState != newState {
      self.state.write(newState)
    }
  }

  private var subscriptions: [Subscription] = []

  private typealias Token = String
  private var activeSubscriptions = Set<Token>()
}
