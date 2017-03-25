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

extension MotionObservableConvertible where T: Hashable {

  /**
   Emits the mapped value for each incoming value, if one exists, otherwise emits nothing.
   */
  public func rewrite<U>(_ values: [T: U]) -> MotionObservable<U> {
    return _nextOperator(#function, args: [values]) { value, next in
      if let mappedValue = values[value] {
        next(mappedValue)
      }
    }
  }

  /**
   Emits the mapped value for each incoming value, if one exists, otherwise emits nothing.
   */
  public func rewrite<U, O: MotionObservableConvertible>(_ values: [T: O]) -> MotionObservable<U> where O.T == U {
    return _nextOperator(#function, args: [values]) { value, next in
      if let mappedValue = values[value], let value = mappedValue._read() {
        next(value)
      }
    }
  }
}
