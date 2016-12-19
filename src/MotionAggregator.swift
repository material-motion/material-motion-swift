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
 A MotionAggregator writes the output of streams to properties and observes their overall state.
 */
public class MotionAggregator {

  /** Creates a motion aggregator instance. */
  public init() {
  }

  /** Subscribes to the stream, writes its output to the given property, and observes its state. */
  public func write<T>(_ stream: MotionObservable<T>, to property: ScopedReactiveProperty<T>) {
    let token = NSUUID().uuidString
    subscriptions.append(stream.subscribe(next: {
      property.write($0)
      property.next($0)

    }, state: { [weak self] state in
      guard let strongSelf = self else { return }
      if state == .active {
        strongSelf.activeSubscriptions.insert(token)
      } else {
        strongSelf.activeSubscriptions.remove(token)
      }

      strongSelf.aggregateState = strongSelf.activeSubscriptions.count > 0 ? .active : .atRest

      property.state(state)
    }))

    let metadata = stream.metadata.with(property.metadata.name,
                                        label: property.metadata.label,
                                        args: property.metadata.args)

    print(metadata.debugDescription)
  }

  public var aggregateState = MotionState.atRest

  private var subscriptions: [Subscription] = []

  typealias Token = String
  private var activeSubscriptions = Set<Token>()
}
