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
@testable import MaterialMotion

class ReactivePropertyTests: XCTestCase {

  // MARK: External writes

  func testExternalWrites() {
    var someVar = 10
    let property = ReactiveProperty(initialValue: someVar, externalWrite: { someVar = $0 })

    XCTAssertEqual(someVar, property.value)

    property.value = 5
    XCTAssertEqual(someVar, 5)

    property.value = 10
    XCTAssertEqual(someVar, property.value)
  }

  // MARK: Comparisons

  func testComparison() {
    let property1 = createProperty(withInitialValue: 10)
    let property2 = createProperty(withInitialValue: 100)
    let property3 = createProperty(withInitialValue: 100)

    XCTAssertTrue(property1 != property2)
    XCTAssertTrue(property2 == property3)
    XCTAssertTrue(property1 == 10)
    XCTAssertTrue(property1 != 100)
  }

  // MARK: Observer events

  func testWritesInformObservers() {
    let property = ReactiveProperty(initialValue: 10)

    let observerReceivedInitialValue = expectation(description: "Observer received initial value")
    let observerReceivedChange = expectation(description: "Observer received changes")
    let subscription = property.subscribeToValue { value in
      if value == 10 {
        observerReceivedInitialValue.fulfill()
      }
      if value == 5 {
        observerReceivedChange.fulfill()
      }
    }

    property.value = 5

    waitForExpectations(timeout: 0)

    subscription.unsubscribe()
  }

  func testWritesDoNotInformObserversWhenUnbsubscribed() {
    let property = ReactiveProperty(initialValue: 10)

    // Expectations will throw when invoked more than once, so we use that behavior to build a test
    // that will throw if the subscription is invoked more than once.
    let observerReceivedInitialValue = expectation(description: "Observer received initial value")
    let subscription = property.subscribeToValue { value in
      observerReceivedInitialValue.fulfill()
    }

    subscription.unsubscribe()

    property.value = 5

    waitForExpectations(timeout: 0)
  }

  // MARK: Core Animation

  func testCoreAnimation() {
    let didReceiveEvent = expectation(description: "Did receive event")
    let property = ReactiveProperty(initialValue: 10, externalWrite: { _ in }, coreAnimation: { event in
      didReceiveEvent.fulfill()
    })

    property.coreAnimation(.remove("key"))

    waitForExpectations(timeout: 0)
  }

  // MARK: shouldVisualizeMotion

  func testshouldVisualizeMotion() {
    let didReceiveEvent = expectation(description: "Did receive event")
    let property = ReactiveProperty(initialValue: 10)
    property.shouldVisualizeMotion = { _ in
      didReceiveEvent.fulfill()
    }

    property.visualize(UIView(), in: UIView())

    waitForExpectations(timeout: 0)
  }

  // MARK: Reactive objects

  func testReactivePropertyInstancesAreIdenticalAcrossInstances() {
    let view = UIView()
    XCTAssertTrue(Reactive(view).isUserInteractionEnabled === Reactive(view).isUserInteractionEnabled)
  }

  func testPropertiesNotReleasedWhenDereferenced() {
    let view = UIView()

    var objectIdentifier: ObjectIdentifier!
    autoreleasepool {
      let prop1 = Reactive(view).isUserInteractionEnabled
      objectIdentifier = ObjectIdentifier(prop1)
    }

    let prop2 = Reactive(view).isUserInteractionEnabled
    XCTAssertTrue(objectIdentifier == ObjectIdentifier(prop2))
  }

  func testObjectRetainedByReactiveType() {
    var reactive: Reactive<UIView>?
    weak var weakView: UIView?

    autoreleasepool {
      let view = UIView()
      weakView = view
      reactive = Reactive(view)
    }

    XCTAssertNotNil(weakView)
    XCTAssertNotNil(reactive)
  }

  func testObjectReleasedWhenReactiveTypeReleased() {
    var reactive: Reactive<UIView>?
    weak var weakView: UIView?

    let allocate = {
      let view = UIView()
      weakView = view
      reactive = Reactive(view)
    }
    allocate()

    reactive = nil

    XCTAssertNil(weakView)

    // Resolve compiler warning about not reading reactive after writing to it.
    XCTAssertNil(reactive)
  }

  func testReactiveObjectNotGloballyRetained() {
    let view = UIView()
    weak var weakReactive: Reactive<UIView>? = Reactive(view)

    XCTAssertNil(weakReactive)
  }

  func testObjectNotGloballyRetained() {
    var view: UIView? = UIView()
    weak var weakView: UIView? = view
    let _ = Reactive(view!)

    view = nil

    XCTAssertNil(weakView)
  }
}
