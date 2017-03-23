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
   Emit a value based on the incoming value's position around a threshold range.

   - paramater min: The minimum threshold.
   - paramater max: The maximum threshold.
   */
  public func thresholdRange(min: T, max: T) -> MotionObservable<ThresholdSide> {
    return _nextOperator(#function, args: [min, max]) { value, next in
      if value < min {
        next(.below)

      } else if value > max {
        next(.above)

      } else {
        next(.within)
      }
    }
  }
}
