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
public func createProperty<T: Zeroable>(_ name: String? = nil) -> ReactiveProperty<T> {
  var value = T.zero() as! T
  return ReactiveProperty(name, initialValue: value, write: { value = $0 })
}

/** Creates a property with a given initial value. */
public func createProperty<T>(_ name: String? = nil, withInitialValue initialValue: T) -> ReactiveProperty<T> {
  var value = initialValue
  return ReactiveProperty(name, initialValue: initialValue, write: { value = $0 })
}

/**
 A reactive property represents a subscribable, readable/writable value.

 Subscribers will receive updates whenever write is invoked.
 */
public final class ReactiveProperty<T> {
  public var value: T {
    get { return _value }
    set {
      _value = newValue

      _write(newValue)

      for observer in observers {
        observer.next(newValue)
      }
    }
  }

  /** Initializes a new instance with the given initial value and write function. */
  public init(_ name: String? = nil, initialValue: T, write: @escaping ScopedWrite<T>) {
    self.metadata = Metadata(name, type: .property)
    self._value = initialValue
    self._write = write
    self._coreAnimation = nil
  }

  /**
   Initializes a new instance with the given initial value, write function, and core animation channel.
   */
  public init(_ name: String? = nil,
              initialValue: T,
              write: @escaping ScopedWrite<T>,
              coreAnimation: @escaping CoreAnimationChannel) {
    self.metadata = Metadata(name, type: .property)
    self._value = initialValue
    self._write = write
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
      observer.coreAnimation(event)
    }
  }

  public let metadata: Metadata

  private var _value: T
  private let _write: ScopedWrite<T>
  private let _coreAnimation: CoreAnimationChannel?

  private var state = MotionState.atRest
  private var coreAnimationEvent: CoreAnimationChannelEvent?

  fileprivate var observers: [MotionObserver<T>] = []
}

public func == <T: Equatable> (left: ReactiveProperty<T>, right: T) -> Bool {
  return left.value == right
}

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

public protocol ReactivePropertyConvertible {
  associatedtype T
  func asProperty() -> ReactiveProperty<T>
}

extension ReactiveProperty: ReactivePropertyConvertible {
  public func asProperty() -> ReactiveProperty<T> {
    return self
  }
}

extension CGFloat: ReactivePropertyConvertible {
  public func asProperty() -> ReactiveProperty<CGFloat> {
    return createProperty("\(type(of: self)) constant = \(self)", withInitialValue: self)
  }
}

extension CGPoint: ReactivePropertyConvertible {
  public func asProperty() -> ReactiveProperty<CGPoint> {
    return createProperty("\(type(of: self)) constant = \(self)", withInitialValue: self)
  }
}
