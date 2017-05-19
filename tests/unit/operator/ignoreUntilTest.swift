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

import XCTest
import IndefiniteObservable
import MaterialMotion

class ignoreUntilTest: XCTestCase {
  func testIgnoreUntil() {

    let input = [20, 10, 60, 50, 10, 20, 80]
    let expected = [50, 10, 20, 80]
    let observable = MotionObservable<Int> { observer in
      for i in input {
        observer.next(i)
      }
      return noopDisconnect
    }

    var values: [Int] = []
    observable.ignoreUntil(50).subscribeToValue {
      values.append($0)
    }
    XCTAssertEqual(values, expected)
  }
}
