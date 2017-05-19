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
    return _map {
      return rubberBand(value: $0, min: below, max: above, bandLength: maxLength)
    }
  }
}

extension MotionObservableConvertible where T == CGPoint {

  /**
   Applies resistance to values that fall outside of the given range.

   Does not modify the value if CGRect is .null.
   */
  public func rubberBanded(outsideOf rect: CGRect, maxLength: CGFloat) -> MotionObservable<CGPoint> {
    return _map {
      guard rect != .null else {
        return $0
      }

      return CGPoint(x: rubberBand(value: $0.x, min: rect.minX, max: rect.maxX, bandLength: maxLength),
                     y: rubberBand(value: $0.y, min: rect.minY, max: rect.maxY, bandLength: maxLength))
    }
  }

  /**
   Applies resistance to values that fall outside of the given range.

   Does not modify the value if CGRect is .null.
   */
  public func rubberBanded<O1, O2>(outsideOf rectStream: O1, maxLength maxLengthStream: O2) -> MotionObservable<CGPoint> where O1: MotionObservableConvertible, O1.T == CGRect, O2: MotionObservableConvertible, O2.T == CGFloat {
    var lastRect: CGRect?
    var lastMaxLength: CGFloat?
    var lastValue: CGPoint?
    return MotionObservable { observer in

      let checkAndEmit = {
        guard let rect = lastRect, let maxLength = lastMaxLength, let value = lastValue else {
          return
        }
        guard lastRect != .null else {
          observer.next(value)
          return
        }
        observer.next(CGPoint(x: rubberBand(value: value.x, min: rect.minX, max: rect.maxX, bandLength: maxLength),
                              y: rubberBand(value: value.y, min: rect.minY, max: rect.maxY, bandLength: maxLength)))
      }

      let rectSubscription = rectStream.subscribeToValue { rect in
        lastRect = rect
        checkAndEmit()
      }

      let maxLengthSubscription = maxLengthStream.subscribeToValue { maxLength in
        lastMaxLength = maxLength
        checkAndEmit()
      }

      let upstreamSubscription = self.subscribeAndForward(to: observer) { value in
        lastValue = value
        checkAndEmit()
      }

      return {
        rectSubscription.unsubscribe()
        maxLengthSubscription.unsubscribe()
        upstreamSubscription.unsubscribe()
      }
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
