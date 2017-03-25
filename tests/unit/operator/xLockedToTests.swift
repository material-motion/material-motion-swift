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

class xLockedToTests: XCTestCase {

  func testValues() {
    let property = createProperty(withInitialValue: CGPoint.zero)

    var values: [CGPoint] = []
    let subscription = property.xLocked(to: 10).subscribeToValue { value in
      values.append(value)
    }

    property.value = .init(x: 50, y: 100)
    property.value = .init(x: -10, y: -50)
    property.value = .init(x: 10, y: 10)

    XCTAssertEqual(values, [.init(x: 10, y: 0),
                            .init(x: 10, y: 100),
                            .init(x: 10, y: -50),
                            .init(x: 10, y: 10)])

    subscription.unsubscribe()
  }
}
