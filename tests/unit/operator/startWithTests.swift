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
import IndefiniteObservable
import MaterialMotion

class startWithTests: XCTestCase {

  func testOverwrittenByReactivePropertyDefaultValue() {
    let property = createProperty(withInitialValue: 0)

    var values: [CGFloat] = []
    let subscription = property.startWith(10).subscribeToValue { value in
      values.append(value)
    }

    property.value = -10

    XCTAssertEqual(values, [0, -10])

    subscription.unsubscribe()
  }

  func testInitializedWithInitialValue() {
    var valueObserver: MotionObserver<CGFloat>?
    let observable = MotionObservable<CGFloat> { observer in
      valueObserver = observer
      return noopDisconnect
    }

    var values: [CGFloat] = []
    let subscription = observable.startWith(10).subscribeToValue { value in
      values.append(value)
    }

    valueObserver?.next(50)

    XCTAssertEqual(values, [10, 50])

    subscription.unsubscribe()
  }

  func testAdditionalSubscriptionsReceiveLatestValue() {
    var valueObserver: MotionObserver<CGFloat>?
    let observable = MotionObservable<CGFloat> { observer in
      valueObserver = observer
      return noopDisconnect
    }

    let stream = observable.startWith(10)

    let subscription = stream.subscribeToValue { value in }

    valueObserver?.next(50)

    var secondValues: [CGFloat] = []
    let secondSubscription = stream.subscribeToValue { value in
      secondValues.append(value)
    }

    XCTAssertEqual(secondValues, [50])

    subscription.unsubscribe()
    secondSubscription.unsubscribe()
  }
}
