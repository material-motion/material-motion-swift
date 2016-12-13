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
@testable import MaterialMotionStreams

class CGPointTests: XCTestCase {

  func testXSubscription() {
    let value: CGFloat = 10

    let observable = MotionObservable<CGPoint> { observer in
      observer.next(.init(x: value, y: value * 2))
      observer.state(.active)
      return noopUnsubscription
    }

    let valueReceived = expectation(description: "Value was received")
    let stateReceived = expectation(description: "State was received")
    let _ = observable.x().subscribe(next: {
      if $0 == value {
        valueReceived.fulfill()
      }
    }, state: { state in
      if state == .active {
        stateReceived.fulfill()
      }
    })

    waitForExpectations(timeout: 0)
  }

  func testYSubscription() {
    let value: CGFloat = 10

    let observable = MotionObservable<CGPoint> { observer in
      observer.next(.init(x: value, y: value * 2))
      observer.state(.active)
      return noopUnsubscription
    }

    let valueReceived = expectation(description: "Value was received")
    let stateReceived = expectation(description: "State was received")
    let _ = observable.y().subscribe(next: {
      if $0 == value * 2 {
        valueReceived.fulfill()
      }
    }, state: { state in
      if state == .active {
        stateReceived.fulfill()
      }
    })

    waitForExpectations(timeout: 0)
  }
}
