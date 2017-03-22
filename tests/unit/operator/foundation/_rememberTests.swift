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
import CoreGraphics
import IndefiniteObservable
import MaterialMotion

class _rememberTests: XCTestCase {

  func testObserversOnlyReceiveLastValue() {
    let value = 10

    let observable = MotionObservable<Int> { observer in
      observer.next(value - 1)
      observer.next(value)
      observer.next(value + 1)
      return noopDisconnect
    }
    let stream = observable._remember()

    let valueReceived = expectation(description: "Value was received")
    let subscription1 = stream.subscribeToValue {
      XCTAssertEqual($0, value + 1)
      valueReceived.fulfill()
    }

    // Should only receive the last-emitted value.
    let receivedOnce = expectation(description: "Value was received once")
    let subscription2 = stream.subscribeToValue {
      XCTAssertEqual($0, value + 1)
      receivedOnce.fulfill()
    }

    waitForExpectations(timeout: 0)

    subscription1.unsubscribe()
    subscription2.unsubscribe()
  }

  func testAsyncObservation() {
    let property = createProperty(withInitialValue: 1)
    let stream = property._remember()

    // Will receive the initial value and all subsequent values.
    let receivedFirst = expectation(description: "First value was received")
    let receivedSecond = expectation(description: "Second value was received")
    let subscription1 = stream.subscribeToValue {
      if $0 == 1 {
        receivedFirst.fulfill()
      } else if $0 == 2 {
        receivedSecond.fulfill()
      }
    }

    property.value = 2

    // Should only receive the last-emitted value.
    let receivedOnce = expectation(description: "Value was received once")
    let subscription2 = stream.subscribeToValue {
      XCTAssertEqual($0, 2)
      receivedOnce.fulfill()
    }

    waitForExpectations(timeout: 0)

    subscription1.unsubscribe()
    subscription2.unsubscribe()
  }
}
