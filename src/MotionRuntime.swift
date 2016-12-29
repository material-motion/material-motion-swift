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
  public func write<T>(_ stream: MotionObservable<T>, to property: ReactiveProperty<T>) {
    let token = NSUUID().uuidString
    subscriptions.append(stream.subscribe(next: property.write, state: { [weak self] state in
      property.state(state)

      guard let strongSelf = self else { return }
      if state == .active {
        strongSelf.activeSubscriptions.insert(token)
      } else {
        strongSelf.activeSubscriptions.remove(token)
      }

      let oldState = strongSelf.state.read()
      let newState: MotionState = strongSelf.activeSubscriptions.count > 0 ? .active : .atRest
      if oldState != newState {
        strongSelf.state.write(newState)
      }

    }, coreAnimation: property.coreAnimation))
  }

  private var subscriptions: [Subscription] = []

  typealias Token = String
  private var activeSubscriptions = Set<Token>()
}
