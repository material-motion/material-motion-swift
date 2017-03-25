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

extension MotionObservableConvertible {

  /**
   Prints any incoming value to the console and then emits the value.

   - parameter context: An optional string to be printed before the value.
   */
  public func log(_ context: String? = nil) -> MotionObservable<T> {
    return _nextOperator(#function, args: [context as Any], operation: { value, next in
      if let context = context {
        print(context, value)
      } else {
        print(value)
      }
      next(value)
    }, coreAnimation: { event, coreAnimation in
      coreAnimation?(event)
    })
  }
}
