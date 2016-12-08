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

/** A scoped property represents a readwrite property for a pre-determined object. */
public class ScopedProperty<V>: ScopedReadable, ScopedWriteable {

  /** A block that, when invoked, returns the property's current value. */
  public let read: () -> V

  /** A block that, when invoked with a value, sets the property's value. */
  public let write: (V) -> Void

  /** Initializes a new instance of ScopedProperty with the given read/write blocks. */
  public init(read: @escaping () -> V, write: @escaping (V) -> Void) {
    self.read = read
    self.write = write
  }
}

/** A scoped readable is able to read from a specific property of pre-determined place. */
public protocol ScopedReadable {
  associatedtype V

  /** The implementing type is expected to return the current value of the backing property. */
  var read: () -> V { get }
}

/** A scoped readable is able to write to a specific property of an object. */
public protocol ScopedWriteable {
  associatedtype V

  /** The implementing type is expected to store the provided value on the backing property. */
  var write: (V) -> Void { get }
}
