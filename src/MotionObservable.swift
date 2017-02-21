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

// Channels are functions that pass values down a stream.

/**
 The canonical value channel on any stream.
 */
public typealias NextChannel<T> = (T) -> Void

/**
 The Core Animation channel shape.
 */
public typealias CoreAnimationChannel = (CoreAnimationChannelEvent) -> Void

/**
 A Core Animation channel event.
 */
public enum CoreAnimationChannelEvent {
  /**
   The provided animation is expected to be added to a layer.
   */
  case add(CAPropertyAnimation, String, initialVelocity: Any?, completionBlock: () -> Void)

  /**
   Any animation with the given key is expected to be removed from a layer.
   */
  case remove(String)

  /**
   The timeline should be observed, and changes in its state should be used to scrub an interaction.
   */
  case timeline(Timeline)
}

/**
 A MotionObservable is a type of [Observable](http://reactivex.io/documentation/observable.html)
 that also supports render server-based Core Animation events.

 Throughout this documentation we will treat the words "observable" and "stream" as synonyms.
 */
public final class MotionObservable<T>: IndefiniteObservable<MotionObserver<T>> {

  /**
   Creates a new motion observable with the provided metadata and connect function.

   The connect function will be invoked each time this observable is subscribed to.
   */
  public init(_ metadata: Metadata, connect: @escaping Connect<MotionObserver<T>>) {
    self.metadata = metadata
    super.init(connect)
  }

  /**
   The provided name is used to create this observable's Metadata information.
   */
  public convenience init(_ name: String? = nil, connect: @escaping Connect<MotionObserver<T>>) {
    self.init(Metadata(name), connect: connect)
  }

  /**
   The metadata describing this stream.
   */
  public let metadata: Metadata

  /**
   Sugar for subscribing a MotionObserver.
   */
  public func subscribe(next: @escaping NextChannel<T>, coreAnimation: @escaping CoreAnimationChannel) -> Subscription {
    return super.subscribe(observer: MotionObserver<T>(next: next, coreAnimation: coreAnimation))
  }

  /**
   Sugar for subscribing a MotionObserver.
   */
  public func subscribe(_ next: @escaping NextChannel<T>) -> Subscription {
    return super.subscribe(observer: MotionObserver<T>(next: next))
  }
}

/**
 A MotionObserver receives values and core animation events from a MotionObservable subscription.
 */
public final class MotionObserver<T>: Observer {
  public typealias Value = T

  public init(next: @escaping NextChannel<T>, coreAnimation: @escaping CoreAnimationChannel) {
    self.next = next
    self.coreAnimation = coreAnimation
  }

  public init(next: @escaping NextChannel<T>) {
    self.next = next
    self.coreAnimation = nil
  }

  public let next: NextChannel<T>
  public let coreAnimation: CoreAnimationChannel?
}

/**
 A MotionObservableConvertible has a canonical MotionObservable that it can return.
 */
public protocol MotionObservableConvertible: Inspectable {
  associatedtype T

  /**
   Returns the canonical MotionObservable for this object.
   */
  func asStream() -> MotionObservable<T>
}

extension MotionObservable: MotionObservableConvertible {
  public func asStream() -> MotionObservable<T> {
    return self
  }
}
