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

// Channels are functions that pass values down the stream.
public typealias NextChannel<T> = (T) -> Void

/** A Core Animation channel event. */
public enum CoreAnimationChannelEvent {
  /** The provided animation is expected to be added to a layer. */
  case add(CAPropertyAnimation, String, initialVelocity: Any?, completionBlock: () -> Void)

  /** Any animation with the given key is expected to be removed from a layer. */
  case remove(String)

  case timeline(Timeline)
}
public typealias CoreAnimationChannel = (CoreAnimationChannelEvent) -> Void

/**
 A MotionObservable is a type of [Observable](http://reactivex.io/documentation/observable.html)
 that specializes in motion systems that can be either active or at rest and potentially emit core
 animation objects.

 Throughout this documentation we will treat the words "observable" and "stream" as synonyms.
 */
public final class MotionObservable<T>: IndefiniteObservable<MotionObserver<T>> {
  /** Sugar for subscribing a MotionObserver. */
  public func subscribe(next: @escaping NextChannel<T>,
                        coreAnimation: @escaping CoreAnimationChannel) -> Subscription {
    return super.subscribe(observer: MotionObserver<T>(next: next, coreAnimation: coreAnimation))
  }
}

/**
 The possible states that a stream can be in.

 What "active" means is stream-dependant. The stream is active if you can answer yes to any of the
 following questions:

 - Is my animation currently animating?
 - Is my physical simulation still moving?
 - Is my gesture recognizer in the .began or .changed state?

 Momentary events such as taps may emit .active immediately followed by .atRest.
 */
public enum MotionState {
  /** The stream is at rest. */
  case atRest

  /** The stream is currently in motion. */
  case active
}

/**
 A MotionObserver receives values, state updates, and core animation objects from a MotionObservable
 subscription.
 */
public final class MotionObserver<T>: Observer {
  public typealias Value = T

  public init(next: @escaping NextChannel<T>, coreAnimation: @escaping CoreAnimationChannel) {
    self.next = next
    self.coreAnimation = coreAnimation
  }

  public let next: NextChannel<T>
  public let coreAnimation: CoreAnimationChannel
}

/** A MotionObservableConvertible has a canonical MotionObservable that it can return. */
public protocol MotionObservableConvertible {
  associatedtype T

  /** Returns the canonical MotionObservable for this object. */
  func asStream() -> MotionObservable<T>
}

extension MotionObservable: MotionObservableConvertible {
  public func asStream() -> MotionObservable<T> {
    return self
  }
}

extension CGFloat: MotionObservableConvertible {
  public func asStream() -> MotionObservable<CGFloat> {
    return self.asProperty().asStream()
  }
}

extension CGPoint: MotionObservableConvertible {
  public func asStream() -> MotionObservable<CGPoint> {
    return self.asProperty().asStream()
  }
}
