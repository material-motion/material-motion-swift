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
import MaterialMotionStreams

// These tests aren't functionally exhaustive because we're depending on IndefiniteObservable's
// tests to be more comprehensive.

class MotionObservableTests: XCTestCase {

  // MARK: Validating data flow

  func testReceivesValue() {
    let value = 10

    let observable = MotionObservable<Int> { observer in
      observer.next(value)
      return noopDisconnect
    }

    let valueReceived = expectation(description: "Value was received")
    let _ = observable.subscribe {
      if $0 == value {
        valueReceived.fulfill()
      }
    }

    waitForExpectations(timeout: 0)
  }

  func testReceivesValueWithCoreAnimationChannel() {
    let value = 10

    let observable = MotionObservable<Int> { observer in
      observer.next(value)
      return noopDisconnect
    }

    let valueReceived = expectation(description: "Value was received")
    let _ = observable.subscribe(next: {
      if $0 == value {
        valueReceived.fulfill()
      }
    }, coreAnimation: { event in
    })

    waitForExpectations(timeout: 0)
  }

  func testReceivesCoreAnimationEventWithCoreAnimationChannel() {
    let observable = MotionObservable<Int> { observer in
      guard let coreAnimation = observer.coreAnimation else {
        XCTAssert(false, "No Core Animation channel available")
        return noopDisconnect
      }
      coreAnimation(.add(CABasicAnimation(), "key", initialVelocity: nil, timeline: nil, completionBlock: { }))
      return noopDisconnect
    }

    let eventReceived = expectation(description: "Event was received")
    let _ = observable.subscribe(next: { value in }, coreAnimation: { event in
      switch event {
      case .add:
        eventReceived.fulfill()
      default:
        XCTAssert(false)
      }
    })

    waitForExpectations(timeout: 0)
  }

  func testReceivesValueWithAllChannels() {
    let value = 10

    let observable = MotionObservable<Int> { observer in
      observer.next(value)
      return noopDisconnect
    }

    let valueReceived = expectation(description: "Value was received")
    let _ = observable.subscribe(next: {
      if $0 == value {
        valueReceived.fulfill()
      }
    }, coreAnimation: { event in
    }, visualization: { view in
    })

    waitForExpectations(timeout: 0)
  }
}
