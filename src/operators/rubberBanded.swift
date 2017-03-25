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

extension MotionObservableConvertible where T == CGFloat {

  /**
   Applies resistance to values that fall outside of the given range.
   */
  public func rubberBanded(below: CGFloat, above: CGFloat, maxLength: CGFloat) -> MotionObservable<CGFloat> {
    return _map(#function, args: [below, above, maxLength]) {
      return rubberBand(value: $0, min: below, max: above, bandLength: maxLength)
    }
  }
}

extension MotionObservableConvertible where T == CGPoint {

  /**
   Applies resistance to values that fall outside of the given range.
   */
  public func rubberBanded(outsideOf rect: CGRect, maxLength: CGFloat) -> MotionObservable<CGPoint> {
    return _map(#function, args: [rect, maxLength]) {
      return CGPoint(x: rubberBand(value: $0.x, min: rect.minX, max: rect.maxX, bandLength: maxLength),
                     y: rubberBand(value: $0.y, min: rect.minY, max: rect.maxY, bandLength: maxLength))
    }
  }
}

private func rubberBand(value: CGFloat, min: CGFloat, max: CGFloat, bandLength: CGFloat) -> CGFloat {
  if value >= min && value <= max {
    // While we're within range we don't rubber band the value.
    return value
  }

  if bandLength <= 0 {
    // The rubber band doesn't exist, return the minimum value so that we stay put.
    return min
  }

  // 0.55 chosen as an approximation of iOS' rubber banding behavior.
  let rubberBandCoefficient: CGFloat = 0.55
  // Accepts values from [0...+inf and ensures that f(x) < bandLength for all values.
  let band: (CGFloat) -> CGFloat = { value in
    let demoninator = value * rubberBandCoefficient / bandLength + 1
    return bandLength * (1 - 1 / demoninator)
  }
  if (value > max) {
    return band(value - max) + max

  } else if (value < min) {
    return min - band(min - value)
  }

  return value
}
