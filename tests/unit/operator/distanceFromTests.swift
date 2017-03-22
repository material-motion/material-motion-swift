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

class distanceFromTests: XCTestCase {

  func testCGFloat() {
    let property = createProperty()

    var values: [CGFloat] = []
    let subscription = property.distance(from: 10).subscribeToValue { value in
      values.append(value)
    }

    property.value = 10
    property.value = 10
    property.value = -10
    property.value = 5

    XCTAssertEqual(values, [10, 0, 0, 20, 5])

    subscription.unsubscribe()
  }

  func testCGPoint() {
    let property = createProperty(withInitialValue: CGPoint(x: 5, y: 0))

    var values: [CGFloat] = []
    let subscription = property.distance(from: .init(x: 5, y: 10)).subscribeToValue { value in
      values.append(value)
    }

    property.value = .init(x: 5, y: 10)
    property.value = .init(x: 50, y: 10)

    XCTAssertEqual(values, [10, 0, 45])

    subscription.unsubscribe()
  }

  func testReactiveCGPoint() {
    let from = createProperty(withInitialValue: CGPoint(x: 5, y: 10))
    let property = createProperty(withInitialValue: CGPoint(x: 5, y: 10))

    var values: [CGFloat] = []
    let subscription = property.distance(from: from).subscribeToValue { value in
      values.append(value)
    }

    property.value = .init(x: 5, y: 0)
    from.value = .init(x: 0, y: 0)

    XCTAssertEqual(values, [0, 10, 5])

    subscription.unsubscribe()
  }
}
