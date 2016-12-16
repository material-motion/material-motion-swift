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
@testable import MaterialMotionStreams

class PropertyObservation: XCTestCase {

  func testUpdatesObserverImmediately() {
    let point = CGPoint(x: 100, y: 100)
    let view = UIView()
    view.center = point
    let property = propertyOf(view).center

    var observedValue: CGPoint? = nil
    let _ = property.subscribe { value in
      observedValue = value
    }
    XCTAssertEqual(observedValue!, point)
  }

  func testUpdatesObserverAfterWrites() {
    let point = CGPoint(x: 100, y: 100)
    let view = UIView()
    let property = propertyOf(view).center

    var observedValue: CGPoint? = nil
    let subscription = property.subscribe { value in
      observedValue = value
    }

    XCTAssertNotEqual(observedValue!, point)

    property.write(point)

    XCTAssertEqual(observedValue!, point)

    subscription.unsubscribe()
  }

  func testDoesNotUpdateObserverAfterWritesWithoutSubscription() {
    let point = CGPoint(x: 100, y: 100)
    let view = UIView()
    let property = propertyOf(view).center

    var observedValue: CGPoint? = nil
    let subscription = property.subscribe { value in
      observedValue = value
    }
    subscription.unsubscribe()

    XCTAssertNotEqual(observedValue!, point)

    property.write(point)

    XCTAssertNotEqual(observedValue!, point)
  }
}
