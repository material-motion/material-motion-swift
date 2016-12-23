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

      let oldState = strongSelf.aggregateState
      let newState: MotionState = strongSelf.activeSubscriptions.count > 0 ? .active : .atRest
      strongSelf.aggregateState = newState
      if oldState != newState {
        strongSelf.delegate?.motionAggregateStateDidChange(strongSelf)
      }

    }, coreAnimation: { animation in
      guard let coreAnimation = property.coreAnimation else {
        assertionFailure("This property does not support core animation.")
        return
      }
      coreAnimation(animation)
    }))
  }

  public private(set) var aggregateState = MotionState.atRest

  /** The delegate to which state change updates should be sent. */
  public weak var delegate: MotionRuntimeDelegate?

  private var subscriptions: [Subscription] = []

  typealias Token = String
  private var activeSubscriptions = Set<Token>()
}

/** A motion runtime delegate is able to receive updates about changes of the aggregate state. */
public protocol MotionRuntimeDelegate: NSObjectProtocol {
  /** Invoked each time the aggregate state changes. */
  func motionAggregateStateDidChange(_ motionAggregate: MotionRuntime)
}
