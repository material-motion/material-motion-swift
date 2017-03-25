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

import Foundation
import UIKit

extension MotionObservableConvertible where T == CGPoint {

  /**
   Emits an anchor point adjustment upon receipt of an anchor point.

   The upstream anchor point should be expressed in normalized units from 0..1, where 0 means the
   top/left-most edge of the view's bounds and 1 means the right/bottom-most edge of the bounds.
   */
  public func anchorPointAdjustment(in view: UIView) -> MotionObservable<AnchorPointAdjustment> {
    return _map(#function, args: [view]) {
      let newPosition = CGPoint(x: $0.x * view.layer.bounds.width, y: $0.y * view.layer.bounds.height)
      let positionInSuperview = view.layer.convert(newPosition, to: view.layer.superlayer)
      return .init(anchorPoint: $0, position: positionInSuperview)
    }
  }
}

/**
 A representation of an anchor point and position adjustment for a CALayer.
 */
public struct AnchorPointAdjustment {
  public let anchorPoint: CGPoint
  public let position: CGPoint
}
