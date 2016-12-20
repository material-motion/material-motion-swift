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

/** Attaches a position to a destination using a spring. */
public class AttachWithSpring: Interaction {

  /** The position to which the position stream is expected to write. */
  public let position: ReactiveProperty<CGPoint>

  /** A stream that emits positional values to be written to the view. */
  public var positionStream: MotionObservable<CGPoint>

  /** The destination to which the spring will pull the view. */
  public let destination: ReactiveProperty<CGPoint>

  /** The initial velocity of the spring. */
  public let initialVelocity: ReactiveProperty<CGPoint>

  /** The spring configuration governing this interaction. */
  public let springConfiguration: ReactiveProperty<SpringConfiguration>

  /**
   - parameter position: The position to be updated by the position stream.
   - parameter destination: The destination property to which the position should spring.
   - parameter springSource: A function capable of creating a spring source.
   */
  public init(position: ReactiveProperty<CGPoint>,
              to destination: ReactiveProperty<CGPoint>,
              springSource: SpringSource<CGPoint>) {
    self.destination = destination
    self.position = position

    let spring = Spring(to: destination, initialValue: position, threshold: 1)
    self.springConfiguration = spring.configuration
    self.initialVelocity = spring.initialVelocity

    let springStream = springSource(spring)
    self.positionStream = springStream
  }

  public func connect(with aggregator: MotionAggregator) {
    aggregator.write(positionStream, to: position)
  }
}
