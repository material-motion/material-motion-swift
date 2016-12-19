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

/** A scoped reactive property represents a readwrite property for a pre-determined object. */
public final class ScopedReactiveProperty<T>: ExtendableMotionObservable, ScopedReadable, ScopedWritable {
  /** A block that, when invoked, returns the property's current value. */
  public let read: ScopedRead<T>
  /** A block that, when invoked, writes the provided value to the backing value. */
  public let write: ScopedWrite<T>

  public var metadata: Metadata

  /** Initializes a new instance with the given read/write blocks. */
  public init(_ name: String, read: @escaping ScopedRead<T>, write: @escaping ScopedWrite<T>) {
    self.read = read
    self.write = write
    self.metadata = Metadata("Scoped property")
    self.metadata = Metadata(pretty(self), label: name)
  }

  public func next(_ value: T) {
    for observer in observers {
      observer.next(value)
    }
  }

  public func state(_ state: MotionState) {
    for observer in observers {
      observer.state(state)
    }
  }

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

  public func subscribe(_ next: @escaping (T) -> Void) -> Subscription {
    return self.subscribe(next: next, state: { _ in })
  }

  private var observers: [MotionObserver<T>] = []
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
  var write: ScopedWrite<T> { get }
}
