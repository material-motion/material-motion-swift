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

import XCTest
import MaterialMotionStreams

class ReactivePropertyTests: XCTestCase {

  func testReadsAndWrites() {
    var someVar = 10
    let property = ReactiveProperty(initialValue: someVar, externalWrite: { someVar = $0 })

    XCTAssertEqual(someVar, property.value)

    property.value = 5
    XCTAssertEqual(someVar, 5)

    property.value = 10
    XCTAssertEqual(someVar, property.value)
  }

  func testComparison() {
    let property1 = createProperty(withInitialValue: 10)
    let property2 = createProperty(withInitialValue: 100)
    let property3 = createProperty(withInitialValue: 100)

    XCTAssertTrue(property1 != property2)
    XCTAssertTrue(property2 == property3)
    XCTAssertTrue(property1 == 10)
    XCTAssertTrue(property1 != 100)
  }
}
