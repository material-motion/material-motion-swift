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

public typealias ScopedRead<T> = () -> T
public typealias ScopedWrite<T> = (T) -> Void

/** A scoped property represents a readwrite property for a pre-determined object. */
public final class ScopedProperty<T>: ScopedReadable, ScopedWritable, ObservableProperty {

  /** A block that, when invoked, returns the property's current value. */
  public let read: ScopedRead<T>

  /** Initializes a new instance of ScopedProperty with the given read/write blocks. */
  public init(read: @escaping ScopedRead<T>, write: @escaping ScopedWrite<T>) {
    self.read = read
    self._write = write
  }

  /** Sets the property's value with the given value. */
  public func write(_ value: T) {
    _write(value)

    for observer in observers {
      observer.next(value)
    }
  }

  public func subscribe(_ next: @escaping (T) -> Void) -> Subscription {
    let observer = ScopedPropertyObserver(next)
    observers.append(observer)

    observer.next(read())

    return Subscription {
      if let index = self.observers.index(where: { $0 === observer }) {
        self.observers.remove(at: index)
      }
    }
  }

  private let _write: ScopedWrite<T>
  private var observers: [ScopedPropertyObserver<T>] = []
}

/** A scoped readable is able to read from a specific property of pre-determined place. */
public protocol ScopedReadable {
  associatedtype T

  /** The implementing type is expected to return the current value. */
  var read: ScopedRead<T> { get }
}

/** A scoped writable is able to write to a specific property of an object. */
public protocol ScopedWritable {
  associatedtype T

  /** The implementing type is expected to store the provided value. */
  func write(_ value: T)
}

/** An observable property informs subscribed observers of writes made to the property. */
public protocol ObservableProperty {
  associatedtype T

  /**
   The provided function will be invoked immediately upon subscription and each time the
   corresponding property is written to.

   Invoke the returned Subscription's unsubscribe method to stop receiving updates.
   */
  func subscribe(_ next: @escaping (T) -> Void) -> Subscription
}

private final class ScopedPropertyObserver<T> {
  init(_ next: @escaping (T) -> Void) {
    self.next = next
  }
  let next: (T) -> Void
}
