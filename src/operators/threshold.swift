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

extension MotionObservableConvertible where T: Comparable {

  /**
   Emit a value based on the incoming value's position around a threshold.

   - paramater threshold: The position of the threshold.
   - paramater whenEqual: The value to emit when the incoming value is equal to threshold.
   - paramater whenBelow: The value to emit when the incoming value is below threshold.
   - paramater whenAbove: The value to emit when the incoming value is above threshold.
   - paramater delta: An optional delta on either side of the threshold.
   */
  public func threshold<U>(_ threshold: T,
                        whenEqual equal: U,
                        whenBelow below: U,
                        whenAbove above: U) -> MotionObservable<U> {
    return asStream()._map {
      if $0 < threshold {
        return below
      }
      if $0 > threshold {
        return above
      }
      return equal
    }
  }

  /**
   Emit a value based on the incoming value's position around a threshold.

   - paramater min: The minimum threshold.
   - paramater max: The maximum threshold.
   - paramater whenWithin: The value to emit when the incoming value is within [min, max].
   - paramater whenBelow: The value to emit when the incoming value is below min.
   - paramater whenAbove: The value to emit when the incoming value is above max.
   */
  public func threshold<U>(min: T,
                        max: T,
                        whenWithin within: U?,
                        whenBelow below: U?,
                        whenAbove above: U?) -> MotionObservable<U> {
    return asStream()._nextOperator { value, next in
      if let below = below, value < min {
        next(below)
      }
      if let above = above, value > max {
        next(above)
      }
      if let within = within, value <= max, value >= min {
        next(within)
      }
    }
  }

  /** Emits either the incoming value or the provided maxValue, whichever is smaller. */
  public func max(_ maxValue: T) -> MotionObservable<T> {
    return asStream()._map {
      return Swift.min($0, maxValue)
    }
  }

  /** Emits either the incoming value or the provided minValue, whichever is larger. */
  public func min(_ minValue: T) -> MotionObservable<T> {
    return asStream()._map {
      return Swift.max($0, minValue)
    }
  }
}
