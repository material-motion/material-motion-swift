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

class anchorPointAdjustmentTests: XCTestCase {

  func testAdjustsAnchorPointWithoutAffectingFrame() {
    let property = createProperty(withInitialValue: CGPoint.zero)

    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let view = UIView(frame: frame)

    var anchorPoints: [CGPoint] = []
    var positions: [CGPoint] = []
    let subscription = property.anchorPointAdjustment(in: view).subscribeToValue { adjustment in
      anchorPoints.append(adjustment.anchorPoint)
      positions.append(adjustment.position)

      view.layer.anchorPoint = adjustment.anchorPoint
      view.layer.position = adjustment.position
    }

    XCTAssertEqual(view.frame, frame)

    property.value = .init(x: 0.5, y: 0.5)

    XCTAssertEqual(view.frame, frame)

    XCTAssertEqual(anchorPoints, [.init(x: 0, y: 0), .init(x: 0.5, y: 0.5)])
    XCTAssertEqual(positions, [.init(x: 0, y: 0), .init(x: 50, y: 50)])

    subscription.unsubscribe()
  }
}
