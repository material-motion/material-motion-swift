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

extension ExtendableMotionObservable where T == CGFloat {

  /**
   Emit a value based on the incoming value's position around a threshold.

   - paramater threshold: The position of the threshold.
   - paramater whenEqual: The value to emit when the incoming value is equal to threshold.
   - paramater whenBelow: The value to emit when the incoming value is below threshold.
   - paramater whenAbove: The value to emit when the incoming value is above threshold.
   - paramater delta: An optional delta on either side of the threshold.
   */
  public func threshold<U>(_ threshold: CGFloat,
                        whenEqual equal: U,
                        whenBelow below: U,
                        whenAbove above: U) -> MotionObservable<U> {
    return _map {
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
  public func threshold<U>(min: CGFloat,
                        max: CGFloat,
                        whenWithin within: U,
                        whenBelow below: U,
                        whenAbove above: U) -> MotionObservable<U> {
    return _map {
      if $0 < min {
        return below
      }
      if $0 > max {
        return above
      }
      return within
    }
  }
}
