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
import MaterialMotionStreams

class SpringTests: XCTestCase {

  func testCGPointInitialization() {
    let view = UIView()
    let target = UIView()
    let spring = Spring(to: propertyOf(target).center,
                        initialValue: propertyOf(view).center,
                        threshold: 1,
                        source: popSpringSource)
    XCTAssertEqual(spring.initialVelocity.read(), .zero)
  }

  func testCGFloatInitialization() {
    let view = UIView()
    let target = UIView()
    let spring = Spring(to: propertyOf(target).centerX,
                        initialValue: propertyOf(view).centerX,
                        threshold: 1,
                        source: popSpringSource)
    XCTAssertEqual(spring.initialVelocity.read(), 0)
  }
}
