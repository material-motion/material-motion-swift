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

class UIViewScopedReactivePropertyTests: XCTestCase {

  func testReads() {
    let view = UIView()

    view.alpha = 0.5
    XCTAssertEqual(propertyOf(view).alpha.read(), view.alpha)

    view.center = .init(x: 100, y: 100)
    XCTAssertEqual(propertyOf(view).centerX.read(), view.center.x)
    XCTAssertEqual(propertyOf(view).centerY.read(), view.center.y)
    XCTAssertEqual(propertyOf(view).center.read(), view.center)
  }

  func testWrites() {
    let view = UIView()

    propertyOf(view).alpha.write(0.5)
    XCTAssertEqual(view.alpha, 0.5)

    propertyOf(view).center.write(.init(x: 100, y: 100))
    XCTAssertEqual(view.center, .init(x: 100, y: 100))

    propertyOf(view).centerX.write(50)
    XCTAssertEqual(view.center.x, 50)

    propertyOf(view).centerY.write(25)
    XCTAssertEqual(view.center.y, 25)
  }

  func testPropertyKeepsObjectAlive() {
    var view: UIView! = UIView()
    weak var weakView = view

    let heldProperty = propertyOf(view).alpha

    view = nil
    XCTAssertNotNil(weakView)

    let _ = heldProperty.read()
  }
}
