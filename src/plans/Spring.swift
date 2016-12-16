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
public final class Spring<T: Zeroable> {

  /** Creates a spring with the provided properties and an initial velocity of zero. */
  public init(to destination: ScopedProperty<T>, initialValue: ScopedProperty<T>, threshold: Float) {
    self.destination = destination
    self.initialValue = initialValue

    var threshold = threshold
    self.threshold = ScopedProperty<Float>(read: { threshold }, write: { threshold = $0 })

    var velocity: T = T.zero() as! T
    self.initialVelocity = ScopedProperty<T>(read: { velocity }, write: { velocity = $0 })

    var configuration = SpringConfiguration.defaultConfiguration
    self.configuration = ScopedProperty<SpringConfiguration>(read: { configuration },
                                                             write: { configuration = $0 })
  }

  /** The destination value of the spring represented as a property. */
  public var destination: ScopedProperty<T>

  /** The initial value of the spring represented as a property. */
  public var initialValue: ScopedProperty<T>

  /** The initial velocity of the spring represented as a property. */
  public var initialVelocity: ScopedProperty<T>

  /** The configuration of the spring represented as a property. */
  public var configuration: ScopedProperty<SpringConfiguration>

  /** The value used when determining completion of the spring simulation. */
  public var threshold: ScopedProperty<Float>
}

/**
 Configure the spring traits for a given property.

 Affects the spring behavior of the SpringTo plan.
 */
public final class SpringConfiguration {
  /**
   The tension coefficient for the property's spring.

   If nil, the spring's tension will not be changed.
   */
  public var tension: CGFloat

  /**
   The friction coefficient for the property's spring.

   If nil, the spring's friction will not be changed.
   */
  public var friction: CGFloat

  /** Initializes the configuration with a given tension and friction. */
  @objc(initWithTension:friction:)
  public init(tension: CGFloat, friction: CGFloat) {
    self.tension = tension
    self.friction = friction
  }

  /**
   The default spring configuration.

   Default extracted from a POP spring with speed = 12 and bounciness = 4.
   */
  public static var defaultConfiguration: SpringConfiguration {
    get {
      // Always return a new instance so that the values can't be changed externally.
      return SpringConfiguration(tension: 342, friction: 30)
    }
  }
}
