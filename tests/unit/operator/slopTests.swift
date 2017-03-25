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

class slopTests: XCTestCase {

  func testInitializedWithinRegionEmitsNothing() {
    let property = createProperty()

    let _ = property.slop(size: 10).subscribeToValue { event in
      assertionFailure("Should not be invoked.")
    }
  }

  func testEmptySlopSize() {
    let property = createProperty()

    var receivedEvents: [SlopEvent] = []
    let subscription = property.slop(size: 0).subscribeToValue { event in
      receivedEvents.append(event)
    }

    property.value = -10
    property.value = 0
    property.value = 10

    XCTAssertEqual(receivedEvents, [.onExit, .onReturn, .onExit])

    subscription.unsubscribe()
  }

  func testWithPositiveSlopSize() {
    let property = createProperty()

    var receivedEvents: [SlopEvent] = []
    let subscription = property.slop(size: 10).subscribeToValue { event in
      receivedEvents.append(event)
    }

    property.value = -10 // Still in slop region. No event.
    property.value = -20 // Exited.
    property.value = -10 // Returned.
    property.value = 10  // Still in region.
    property.value = 20  // Exited.
    property.value = 0   // Returned.

    XCTAssertEqual(receivedEvents, [.onExit, .onReturn, .onExit, .onReturn])

    subscription.unsubscribe()
  }

  func testWithNegativeSlopSize() {
    let property = createProperty()

    var receivedEvents: [SlopEvent] = []
    let subscription = property.slop(size: -10).subscribeToValue { event in
      receivedEvents.append(event)
    }

    property.value = -10 // Still in slop region. No event.
    property.value = -20 // Exited.
    property.value = -10 // Returned.
    property.value = 10  // Still in region.
    property.value = 20  // Exited.
    property.value = 0   // Returned.

    XCTAssertEqual(receivedEvents, [.onExit, .onReturn, .onExit, .onReturn])

    subscription.unsubscribe()
  }
}
