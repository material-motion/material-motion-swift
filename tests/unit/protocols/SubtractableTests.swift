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
import MaterialMotion

class SubtractableTests: XCTestCase {

  func testCGPoint() {
    let value1 = CGPoint(x: 1, y: 2)
    let value2 = CGPoint(x: 4, y: 3)

    XCTAssertEqual(value1 - value2, CGPoint(x: -3, y: -1))
  }

  func testCGSize() {
    let value1 = CGSize(width: 1, height: 2)
    let value2 = CGSize(width: 4, height: 3)

    XCTAssertEqual(value1 - value2, CGSize(width: -3, height: -1))
  }

  func testCGRect() {
    let value1 = CGRect(x: 1, y: 2, width: 3, height: 4)
    let value2 = CGRect(x: 8, y: 7, width: 6, height: 5)

    XCTAssertEqual(value1 - value2, CGRect(x: -7, y: -5, width: -3, height: -1))
  }
}
