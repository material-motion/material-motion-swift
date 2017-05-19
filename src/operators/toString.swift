/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

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
import CoreGraphics

extension MotionObservableConvertible {

  /**
   Emits a string representation of the incoming value.
   */
  public func toString() -> MotionObservable<String> {
    return _map { String(describing: $0) }
  }
}

extension MotionObservableConvertible where T == CGFloat {

  /**
   Emits a string representation of the incoming value.

   The incoming value may optionally be formatted according to the provided format string.
   */
  public func toString(format: String) -> MotionObservable<String> {
    return _map { String(format: format, $0) }
  }
}
