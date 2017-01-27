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

/** Attaches a position to a destination on either side of a transition using a spring. */
public class TransitionSpring<T: Zeroable>: PropertyInteraction, TransitionInteraction {

  public let backwardDestination: T
  public let forwardDestination: T

  /** A stream that writes to the spring's destination when the transition's direction changes. */
  public private(set) var destinationStream: MotionObservable<T>

  public var directionStream: MotionObservable<Transition.Direction> {
    didSet {
      self.destinationStream = self.destinationStream.merge(with: directionStream.destinations(back: backwardDestination,
                                                                                               fore: forwardDestination))
    }
  }

  public var initialVelocityStream: MotionObservable<T>

  public func add(initialVelocityStream stream: MotionObservable<T>) {
    initialVelocityStream = initialVelocityStream.merge(with: stream)
  }

  private var compositions: [(MotionObservable<T>) -> MotionObservable<T>] = []
  public func compose(stream: @escaping (MotionObservable<T>) -> MotionObservable<T>) {
    compositions.append(stream)
  }

  /** The tension configuration of the spring. */
  public let tension: ReactiveProperty<CGFloat>

  /** The friction configuration of the spring. */
  public let friction: ReactiveProperty<CGFloat>

  public var system: SpringToStream<T>

  /**
   - parameter value: The property to be updated by the value stream.
   - parameter back: The destination to which the spring will pull the view when transitioning
                     backward.
   - parameter fore: The destination to which the spring will pull the view when transitioning
                     forward.
   - parameter direction: The spring will change its destination in reaction to this property's
                          changes.
   - parameter system A function capable of creating a spring source.
   */
  public init(back backwardDestination: T,
              fore forwardDestination: T,
              direction: ReactiveProperty<Transition.Direction>,
              system: @escaping SpringToStream<T>) {
    self.backwardDestination = backwardDestination
    self.forwardDestination = forwardDestination
    self.system = system
    self.directionStream = direction.stream
    self.destinationStream = directionStream.destinations(back: backwardDestination,
                                                          fore: forwardDestination)
    self.initialVelocityStream = createProperty(withInitialValue: T.zero() as! T).stream

    self.tension = createProperty(withInitialValue: defaultSpringTension)
    self.friction = createProperty(withInitialValue: defaultSpringFriction)

    self._initialValue = direction == .forward ? backwardDestination : forwardDestination
  }

  public func add(to property: ReactiveProperty<T>, withRuntime runtime: MotionRuntime) {
    var stream = Spring(to: destinationStream,
                        initialVelocity: initialVelocityStream,
                        threshold: 1,
                        system: system).stream(withInitialValue: property)
    runtime.add(compositions.reduce(stream) { $1($0) }, to: property)
  }

  public func initialValue() -> T {
    return _initialValue
  }

  private let _initialValue: T
}
