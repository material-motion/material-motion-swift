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
import CoreGraphics
import IndefiniteObservable
@testable import ReactiveMotion

class _filterTests: XCTestCase {

  func testSubscription() {
    let value = 10

    let observable = MotionObservable<Int>(Metadata("")) { observer in
      observer.next(value - 1)
      observer.next(value)
      observer.next(value + 1)
      return noopDisconnect
    }

    let valueReceived = expectation(description: "Value was received")
    let _ = observable._filter(Metadata("")) { value in
      return value == 10

    }.subscribe {
      if $0 == value {
        valueReceived.fulfill()
      }
    }

    waitForExpectations(timeout: 0)
  }
}
