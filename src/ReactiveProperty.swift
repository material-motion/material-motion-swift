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
 Creates a property with an initial value of zero.
 */
public func createProperty<T: Zeroable>(_ name: String? = nil) -> ReactiveProperty<T> {
  return ReactiveProperty(name, initialValue: T.zero() as! T)
}

/**
 Creates a property with a given initial value.
 */
public func createProperty<T>(_ name: String? = nil, withInitialValue initialValue: T) -> ReactiveProperty<T> {
  return ReactiveProperty(name, initialValue: initialValue)
}

/**
 A reactive property represents an observable value.
 */
public final class ReactiveProperty<T> {

  /**
   The value backing this property.

   Writes to this value will immediately be propagated to all subscribed observers.
   */
  public var value: T {
    didSet {
      _externalWrite?(value)

      for observer in observers {
        observer.next(value)
      }
    }
  }

  /**
   Creates a new anonymous property.
   */
  public init(_ name: String? = nil, initialValue: T) {
    self.metadata = Metadata(name, type: .property)
    self.value = initialValue
    self._externalWrite = nil
    self._coreAnimation = nil
  }

  /**
   Creates a property that writes to some external information.
   */
  public init(_ name: String? = nil, initialValue: T, externalWrite: @escaping NextChannel<T>) {
    self.metadata = Metadata(name, type: .property)
    self.value = initialValue
    self._externalWrite = externalWrite
    self._coreAnimation = nil
  }

  /**
   Creates a property that writes to some external information and supports Core Animation.
   */
  public init(_ name: String? = nil,
              initialValue: T,
              externalWrite: @escaping NextChannel<T>,
              coreAnimation: @escaping CoreAnimationChannel) {
    self.metadata = Metadata(name, type: .property)
    self.value = initialValue
    self._externalWrite = externalWrite
    self._coreAnimation = coreAnimation
  }

  /**
   Forwards the invocation to the channel if a core animation channel was provided to this property,
   otherwise throws an assertion.
   */
  public func coreAnimation(_ event: CoreAnimationChannelEvent) {
    guard let coreAnimation = _coreAnimation else {
      return
    }

    coreAnimationEvent = event
    coreAnimation(event)

    for observer in observers {
      observer.coreAnimation?(event)
    }
  }

  /**
   The metadata describing this property.
   */
  public let metadata: Metadata

  private let _externalWrite: NextChannel<T>?
  private let _coreAnimation: CoreAnimationChannel?

  private var state = MotionState.atRest
  private var coreAnimationEvent: CoreAnimationChannelEvent?

  fileprivate var observers: [MotionObserver<T>] = []
}

extension ReactiveProperty where T: Equatable {
  /**
   Two reactive properties are equal if their backing values are equal.
   */
  public static func == (left: ReactiveProperty<T>, right: ReactiveProperty<T>) -> Bool {
    return left.value == right.value
  }

  public static func == (left: ReactiveProperty<T>, right: T) -> Bool {
    return left.value == right
  }

  /**
   Two reactive properties are not equal if their backing values are not equal.
   */
  public static func != (left: ReactiveProperty<T>, right: ReactiveProperty<T>) -> Bool {
    return left.value != right.value
  }

  public static func != (left: ReactiveProperty<T>, right: T) -> Bool {
    return left.value != right
  }
}

// Reactive properties can be used as streams.
extension ReactiveProperty: MotionObservableConvertible {
  public func asStream() -> MotionObservable<T> {
    return MotionObservable<T>(metadata) { observer in
      self.observers.append(observer)

      observer.next(self.value)

      return {
        if let index = self.observers.index(where: { $0 === observer }) {
          self.observers.remove(at: index)
        }
      }
    }
  }
}

/**
 An extensible type allowing classes to be treated as properties.
 */
public protocol ReactivePropertyConvertible {
  associatedtype T

  /**
   Returns the canonical ReactiveProperty for this object.
   */
  func asProperty() -> ReactiveProperty<T>
}

extension ReactiveProperty: ReactivePropertyConvertible {
  public func asProperty() -> ReactiveProperty<T> {
    return self
  }
}
