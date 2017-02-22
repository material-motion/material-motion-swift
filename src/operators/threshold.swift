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
   - paramater whenBelow: The value to emit when the incoming value is below threshold.
   - paramater whenEqual: The value to emit when the incoming value is equal to threshold.
   - paramater whenAbove: The value to emit when the incoming value is above threshold.
   - paramater delta: An optional delta on either side of the threshold.
   */
  public func threshold<U>
    ( _ threshold: T,
      whenBelow below: U?,
      whenEqual equal: U?,
      whenAbove above: U?
    ) -> MotionObservable<U> {
    return _nextOperator(Metadata("\(#function)", args: [threshold, below, equal, above])) { value, next in
      if let below = below, value < threshold {
        next(below)
      }
      if let above = above, value > threshold {
        next(above)
      }
      if let equal = equal {
        next(equal)
      }
    }
  }
}
