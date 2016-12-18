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
  public convenience init(to destination: ScopedReactiveProperty<T>, initialValue: ScopedReactiveProperty<T>, threshold: CGFloat) {
    var velocity: T = T.zero() as! T
    let initialVelocity = ScopedReactiveProperty<T>(read: { velocity }, write: { velocity = $0 })
    self.init(to: destination, initialValue: initialValue, initialVelocity: initialVelocity, threshold: threshold)
  }

  /** Creates a spring with the provided properties and an initial velocity. */
  public init(to destination: ScopedReactiveProperty<T>,
              initialValue: ScopedReactiveProperty<T>,
              initialVelocity: ScopedReactiveProperty<T>,
              threshold: CGFloat) {
    self.destination = destination
    self.initialValue = initialValue
    self.initialVelocity = initialVelocity

    var threshold = threshold
    self.threshold = ScopedReactiveProperty<CGFloat>(read: { threshold }, write: { threshold = $0 })

    var configuration = SpringConfiguration.defaultConfiguration
    self.configuration = ScopedReactiveProperty<SpringConfiguration>(read: { configuration },
                                                             write: { configuration = $0 })
  }

  /** The destination value of the spring represented as a property. */
  public let destination: ScopedReactiveProperty<T>

  /** The initial value of the spring represented as a property. */
  public let initialValue: ScopedReactiveProperty<T>

  /** The initial velocity of the spring represented as a property. */
  public let initialVelocity: ScopedReactiveProperty<T>

  /** The configuration of the spring represented as a property. */
  public let configuration: ScopedReactiveProperty<SpringConfiguration>

  /** The value used when determining completion of the spring simulation. */
  public let threshold: ScopedReactiveProperty<CGFloat>
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
