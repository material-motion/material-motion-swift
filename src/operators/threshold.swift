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

public enum ThresholdEvent {
  case whenBelow
  case whenWithin
  case whenAbove
}

extension MotionObservableConvertible where T: Comparable {

  /**
   Emit a value based on the incoming value's position around a threshold.

   - paramater threshold: The position of the threshold.
   */
  public func threshold(_ threshold: T) -> MotionObservable<ThresholdEvent> {
    return _nextOperator(Metadata(#function, args: [threshold])) { value, next in
      if value < threshold {
        next(.whenBelow)

      } else if value > threshold {
        next(.whenAbove)

      } else {
        next(.whenWithin)
      }
    }
  }
}
