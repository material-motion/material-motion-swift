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

/** The expected shape of a write function. */
public typealias ScopedWrite<T> = (T) -> Void

/** Creates a property with a given initial value. */
public func createProperty<T>(withInitialValue initialValue: T) -> ReactiveProperty<T> {
  var value = initialValue
  return ReactiveProperty(initialValue: initialValue, write: { value = $0 })
}

/**
 A reactive property represents a subscribable, readable/writable value.

 Subscribers will receive updates whenever write is invoked.
 */
public final class ReactiveProperty<T> {
  public private(set) var value: T

  public lazy var stream: MotionObservable<T> = {
    let stream = MotionObservable<T> { observer in
      self.observers.append(observer)

      if self.state == .active {
        observer.state(.active)
      }
      observer.next(self.value)
      if self.state == .atRest {
        observer.state(.atRest)
      }

      return {
        if let index = self.observers.index(where: { $0 === observer }) {
          self.observers.remove(at: index)
        }
      }
    }
    return stream
  }()

  /** Initializes a new instance with the given initial value and write function. */
  public init(initialValue: T, write: @escaping ScopedWrite<T>) {
    self.value = initialValue
    self._write = write
    self._coreAnimation = nil
  }

  /**
   Initializes a new instance with the given initial value, write function, and core animation channel.
   */
  public init(initialValue: T,
              write: @escaping ScopedWrite<T>,
              coreAnimation: @escaping CoreAnimationChannel) {
    self.value = initialValue
    self._write = write
    self._coreAnimation = coreAnimation
  }

  /** Writes the value and informs all observers of the new value. */
  public func setValue(_ value: T) {
    self.value = value

    _write(value)

    for observer in observers {
      observer.next(value)
    }
  }

  /** Informs all observers of the given state. */
  public func state(_ state: MotionState) {
    self.state = state

    for observer in observers {
      observer.state(state)
    }
  }

  /**
   Forwards the invocation to the channel if a core animation channel was provided to this property,
   otherwise throws an assertion.
   */
  public func coreAnimation(_ event: CoreAnimationChannelEvent) {
    guard let coreAnimation = _coreAnimation else {
      assertionFailure("This property does not support core animation.")
      return
    }

    coreAnimationEvent = event
    coreAnimation(event)

    for observer in observers {
      observer.coreAnimation(event)
    }
  }

  private let _write: ScopedWrite<T>
  private let _coreAnimation: CoreAnimationChannel?

  private var state = MotionState.atRest
  private var coreAnimationEvent: CoreAnimationChannelEvent?

  private var observers: [MotionObserver<T>] = []
}

public func == <T: Equatable> (left: ReactiveProperty<T>, right: T) -> Bool {
  return left.value == right
}

extension ReactiveProperty: MotionObservableConvertible {
  public func asStream() -> MotionObservable<T> {
    return stream
  }
}
