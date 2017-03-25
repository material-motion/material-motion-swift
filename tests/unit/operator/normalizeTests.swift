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

class normalizeTests: XCTestCase {

  func testCGFloatByCGFloat() {
    let property = createProperty()

    var values: [CGFloat] = []
    let subscription = property.normalized(by: 100).subscribeToValue { value in
      values.append(value)
    }

    property.value = 10
    property.value = 150
    property.value = -10

    XCTAssertEqual(values, [0, 0.1, 1.5, -0.1])

    subscription.unsubscribe()
  }

  func testCGPointByCGSize() {
    let property = createProperty(withInitialValue: CGPoint.zero)

    var values: [CGPoint] = []
    let subscription = property.normalized(by: CGSize(width: 100, height: 50)).subscribeToValue { value in
      values.append(value)
    }

    property.value = .init(x: 50, y: 50)
    property.value = .init(x: 100, y: 20)
    property.value = .init(x: -50, y: -20)

    XCTAssertEqual(values, [.init(x: 0, y: 0),
                            .init(x: 0.5, y: 1.0),
                            .init(x: 1, y: 0.4),
                            .init(x: -0.5, y: -0.4)])

    subscription.unsubscribe()
  }
}
