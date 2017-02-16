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

/**
 A Spring can pull a value from an initial position to a destination using a physical simulation.

 This class defines the expected shape of a Spring for use in creating a Spring source.
 */
public class Spring<T: Zeroable>: PropertyInteraction, ViewInteraction {
  /** Creates a spring with the provided properties and an initial velocity. */
  public init(threshold: CGFloat, system: @escaping SpringToStream<T>) {
    self.threshold = createProperty(withInitialValue: threshold)
    self.system = system
  }

  public let enabled = createProperty(withInitialValue: true)

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }

  public let initialValue: ReactiveProperty<T> = createProperty()

  /** The initial velocity of the spring represented as a stream. */
  public let initialVelocity: ReactiveProperty<T> = createProperty()

  /** The destination value of the spring represented as a property. */
  public let destination: ReactiveProperty<T> = createProperty()

  /** The tension configuration of the spring represented as a property. */
  public let tension = createProperty(withInitialValue: defaultSpringTension)

  /** The friction configuration of the spring represented as a property. */
  public let friction = createProperty(withInitialValue: defaultSpringFriction)

  /** The mass configuration of the spring represented as a property. */
  public let mass = createProperty(withInitialValue: defaultSpringMass)

  /**
   The suggested duration of the spring represented as a property.

   This property may not be supported by all animation systems.

   A value of 0 means this property will be ignored.
   */
  public let suggestedDuration = createProperty(withInitialValue: TimeInterval(0))

  /** The value used when determining completion of the spring simulation. */
  public let threshold: ReactiveProperty<CGFloat>

  fileprivate var stream: MotionObservable<T>?
  fileprivate let system: SpringToStream<T>
  fileprivate let _state = createProperty(withInitialValue: MotionState.atRest)

  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    if let castedSelf = self as? Spring<CGPoint> {
      let position = reactiveView.reactiveLayer.position
      runtime.add(position.asStream(), to: castedSelf.initialValue)
      runtime.add(castedSelf.asStream(), to: position)
    }
  }

  public func add(to property: ReactiveProperty<T>, withRuntime runtime: MotionRuntime) {
    runtime.add(property.asStream(), to: initialValue)
    runtime.add(asStream(), to: property)
  }
}

public struct SpringShadow<T: Zeroable> {
  public let enabled: ReactiveProperty<Bool>
  public let state: ReactiveProperty<MotionState>
  public let initialValue: ReactiveProperty<T>
  public let initialVelocity: ReactiveProperty<T>
  public let destination: ReactiveProperty<T>
  public let tension: ReactiveProperty<CGFloat>
  public let friction: ReactiveProperty<CGFloat>
  public let mass: ReactiveProperty<CGFloat>
  public let suggestedDuration: ReactiveProperty<TimeInterval>
  public let threshold: ReactiveProperty<CGFloat>

  init(of spring: Spring<T>) {
    self.enabled = spring.enabled
    self.state = spring._state
    self.initialValue = spring.initialValue
    self.initialVelocity = spring.initialVelocity
    self.destination = spring.destination
    self.tension = spring.tension
    self.friction = spring.friction
    self.mass = spring.mass
    self.suggestedDuration = spring.suggestedDuration
    self.threshold = spring.threshold
  }
}

extension Spring: MotionObservableConvertible {
  public func asStream() -> MotionObservable<T> {
    if stream == nil {
      stream = system(SpringShadow(of: self)).multicast()
    }
    return stream!
  }
}

/** The default tension configuration. */
public let defaultSpringTension: CGFloat = 342

/** The default friction configuration. */
public let defaultSpringFriction: CGFloat = 30

/** The default mass configuration. */
public let defaultSpringMass: CGFloat = 1
