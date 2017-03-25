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

class mergeTests: XCTestCase {

  func testValuesAreEmitted() {
    let property = createProperty()
    let otherProperty = createProperty(withInitialValue: 1)

    var values: [CGFloat] = []
    let subscription = property.merge(with: otherProperty).subscribeToValue { value in
      values.append(value)
    }

    property.value = -10
    otherProperty.value = 5

    XCTAssertEqual(values, [0, 1, -10, 5])

    subscription.unsubscribe()
  }
}
