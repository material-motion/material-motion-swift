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

/** A tween describes a potential interpolation from one value to another. */
public final class Tween<T> {

  /** The duration of the animation in seconds. */
  public var duration: CFTimeInterval

  /** The delay of the animation in seconds. */
  public var delay: CFTimeInterval = 0

  /**
   An array of objects providing the value of the animation for each keyframe.

   If values.count == 1 then the sole value will be treated as the toValue in a basic animation.

   See CAKeyframeAnimation documentation for more details.
   */
  public var values: [T]

  /**
   An optional array of double values defining the pacing of the animation. Each position
   corresponds to one value in the `values' array, and defines when the value should be used in the
   animation function. Each value in the array is a floating point number in the range [0,1].

   See CAKeyframeAnimation documentation for more details.
   */
  public var keyPositions: [Double]?

  /**
   An optional array of CAMediaTimingFunction objects. If the `values' array defines n keyframes,
   there should be n-1 objects in the `timingFunctions' array. Each function describes the pacing of
   one keyframe to keyframe segment.

   If values.count == 1 then a single timing function may be provided to configure the basic
   animation.

   See CAKeyframeAnimation documentation for more details.
   */
  public var timingFunctions: [CAMediaTimingFunction]?

  /** Initializes a tween instance with its required properties. */
  public init(duration: CFTimeInterval, values: [T]) {
    self.duration = duration
    self.values = values
  }
}
