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

/** The expected shape of a read function. */
public typealias ScopedRead<T> = () -> T

/** The expected shape of a write function. */
public typealias ScopedWrite<T> = (T) -> Void

/** Creates a property with a given initial value. */
public func createProperty<T>(withInitialValue initialValue: T) -> ReactiveProperty<T> {
  var value = initialValue
  return ReactiveProperty(read: { value }, write: { value = $0 })
}

/**
 A reactive property represents a subscribable, readable/writable value.

 Subscribers will receive updates whenever write is invoked.
 */
public final class ReactiveProperty<T>: Readable, Writable, ExtendableMotionObservable {

  /** Initializes a new instance with the given read/write functions. */
  public init(read: @escaping ScopedRead<T>, write: @escaping ScopedWrite<T>) {
    self._read = read
    self._write = write
  }

  /** Returns the current value. */
  public func read() -> T {
    return _read()
  }

  /** Writes the value and informs all observers of the new value. */
  public func write(_ value: T) {
    _write(value)

    for observer in observers {
      observer.next(value)
    }
  }

  /** Informs all observers of the given state. */
  public func state(_ state: MotionState) {
    for observer in observers {
      observer.state(state)
    }
  }

  /**
   Adds a new observer to the property.

   Invoke unsubscribe on the returned subscription in order to stop receiving new values.
   */
  public func subscribe(next: @escaping NextChannel<T>, state: @escaping StateChannel) -> Subscription {
    let observer = MotionObserver(next: next, state: state)
    observers.append(observer)

    observer.next(read())

    return Subscription {
      if let index = self.observers.index(where: { $0 === observer }) {
        self.observers.remove(at: index)
      }
    }
  }

  /** A convenience function for subscribe that provides an empty state subscription. */
  public func subscribe(_ next: @escaping (T) -> Void) -> Subscription {
    return self.subscribe(next: next, state: { _ in })
  }

  private let _read: ScopedRead<T>
  private let _write: ScopedWrite<T>
  private var observers: [MotionObserver<T>] = []
}

/** A readable is able to read from a value. */
public protocol Readable {
  associatedtype T

  /** Returns the current value. */
  func read() -> T
}

/** A writable is able to write to a value. */
public protocol Writable {
  associatedtype T

  /** Stores the provided value. */
  func write(_ value: T)
}
