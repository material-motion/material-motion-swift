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
 Attaches a property to a destination using a spring.

 The spring's initial position will be the property's initial value. valueStream will emit values
 that will cause the property to animate from its initial value to the destination property.
 */
public class AttachWithSpring<T: Zeroable>: Interaction {

  /** The property to which the value stream is expected to write. */
  public let property: ReactiveProperty<T>

  /** A stream that emits values to be written to the property. */
  public var valueStream: MotionObservable<T>

  /** The spring governing this interaction. */
  public let spring: Spring<T>

  /**
   - parameter property: The property to be updated by the value stream.
   - parameter destination: The destination property to which the property should spring.
   - parameter threshold: The value used when determining completion of the simulation. Smaller
                          values mean greater required precision.
   - parameter springSource: A function capable of creating a spring source.
   */
  public init(property: ReactiveProperty<T>,
              to destination: ReactiveProperty<T>,
              threshold: CGFloat,
              springSource: SpringSource<T>) {
    self.property = property

    self.spring = Spring(to: destination, initialValue: property, threshold: threshold, source: springSource)
    self.valueStream = self.spring.valueStream
  }

  public func connect(with runtime: MotionRuntime) {
    runtime.write(valueStream, to: property)
  }
}
