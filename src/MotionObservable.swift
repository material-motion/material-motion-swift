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
 A MotionObservable is a type of [Observable](http://reactivex.io/documentation/observable.html)
 that specializes in motion systems that can be either active or at rest.

 Throughout this documentation we will treat the words "observable" and "stream" as synonyms.

 Spec: https://material-motion.github.io/material-motion/starmap/specifications/streams/MotionObservable
 */
public class MotionObservable<V>: IndefiniteObservable<MotionObserver<V>> {

  /** Sugar for subscribing a MotionObserver. */
  public func subscribe(next: @escaping (V) -> Void,
                        state: @escaping (MotionState) -> Void) -> Subscription {
    return super.subscribe(observer: MotionObserver<V>(next: next, state: state))
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

// Used internally to store observer state.
final class MotionObserver<V>: Observer {
  public typealias Value = V

  public init(next: @escaping (V) -> Void,
              state: @escaping (MotionState) -> Void) {
    self.next = next
    self.state = state
  }

  public let next: (V) -> Void
  public let state: (MotionState) -> Void
}
