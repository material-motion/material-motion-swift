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
 A Spring can pull a value from an initial position to a destination using a physical simulation.

 This class defines the expected shape of a Spring for use in creating a Spring source.
 */
public class Spring<T: Zeroable>: PropertyInteraction, ViewInteraction {
  /** Creates a spring with the provided properties and an initial velocity. */
  public init(threshold: CGFloat, system: @escaping SpringToStream<T>) {
    self.threshold = createProperty("Spring.threshold", withInitialValue: threshold)
    self.system = system
  }

  public let enabled = createProperty("Spring.enabled", withInitialValue: true)

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }

  /** The initial velocity of the spring represented as a stream. */
  public let initialVelocity: ReactiveProperty<T> = createProperty("Spring.initialVelocity")

  /** The destination value of the spring represented as a property. */
  public let destination: ReactiveProperty<T> = createProperty("Spring.destination")

  /** The tension configuration of the spring represented as a property. */
  public let tension = createProperty("Spring.tension", withInitialValue: defaultSpringTension)

  /** The friction configuration of the spring represented as a property. */
  public let friction = createProperty("Spring.friction", withInitialValue: defaultSpringFriction)

  /** The mass configuration of the spring represented as a property. */
  public let mass = createProperty("Spring.mass", withInitialValue: defaultSpringMass)

  /**
   The suggested duration of the spring represented as a property.

   This property may not be supported by all animation systems.

   A value of 0 means this property will be ignored.
   */
  public let suggestedDuration = createProperty("Spring.suggestedDuration", withInitialValue: TimeInterval(0))

  /** The value used when determining completion of the spring simulation. */
  public let threshold: ReactiveProperty<CGFloat>

  public let metadata = Metadata("Spring")

  fileprivate let system: SpringToStream<T>
  fileprivate let _state = createProperty("Spring._state", withInitialValue: MotionState.atRest)

  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    if let castedSelf = self as? Spring<CGPoint> {
      castedSelf.add(to: reactiveView.reactiveLayer.position, withRuntime: runtime)
    }
  }

  public func add(to property: ReactiveProperty<T>, withRuntime runtime: MotionRuntime) {
    let shadow = SpringShadow(of: self, initialValue: property)
    runtime.add(shadow.state.dedupe(), to: ReactiveProperty(initialValue: .atRest) { state in
      if state == .active {
        self.activeSprings.insert(shadow)
      } else {
        self.activeSprings.remove(shadow)
      }
      self._state.value = self.activeSprings.count == 0 ? .atRest : .active
    })
    runtime.add(system(shadow), to: property)
  }

  private var activeSprings = Set<SpringShadow<T>>()
}

public struct SpringShadow<T: Zeroable>: Hashable {
  public let enabled: ReactiveProperty<Bool>
  public let state = createProperty(withInitialValue: MotionState.atRest)
  public let initialValue: ReactiveProperty<T>
  public let initialVelocity: ReactiveProperty<T>
  public let destination: ReactiveProperty<T>
  public let tension: ReactiveProperty<CGFloat>
  public let friction: ReactiveProperty<CGFloat>
  public let mass: ReactiveProperty<CGFloat>
  public let suggestedDuration: ReactiveProperty<TimeInterval>
  public let threshold: ReactiveProperty<CGFloat>

  init(of spring: Spring<T>, initialValue: ReactiveProperty<T>) {
    self.enabled = spring.enabled
    self.initialValue = initialValue
    self.initialVelocity = spring.initialVelocity
    self.destination = spring.destination
    self.tension = spring.tension
    self.friction = spring.friction
    self.mass = spring.mass
    self.suggestedDuration = spring.suggestedDuration
    self.threshold = spring.threshold
  }

  private let uuid = NSUUID().uuidString
  public var hashValue: Int {
    return uuid.hashValue
  }

  public static func ==(lhs: SpringShadow<T>, rhs: SpringShadow<T>) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}

/** The default tension configuration. */
public let defaultSpringTension: CGFloat = 342

/** The default friction configuration. */
public let defaultSpringFriction: CGFloat = 30

/** The default mass configuration. */
public let defaultSpringMass: CGFloat = 1
