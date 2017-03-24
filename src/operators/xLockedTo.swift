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
   Lock the point's x value to the given value.
   */
  public func xLocked(to xValue: CGFloat) -> MotionObservable<CGPoint> {
    return _map(#function, args: [xValue]) {
      .init(x: xValue, y: $0.y)
    }
  }

  /**
   Lock the point's x value to the given reactive value.
   */
  public func xLocked<O: MotionObservableConvertible>(to xValueStream: O) -> MotionObservable<CGPoint> where O.T == CGFloat {
    var lastUpstreamValue: CGPoint?
    var lastXValue: CGFloat?
    return MotionObservable(self.metadata.createChild(Metadata(#function, type: .constraint, args: [xValueStream]))) { observer in

      let checkAndEmit = {
        guard let lastUpstreamValue = lastUpstreamValue, let lastXValue = lastXValue else { return }

        observer.next(.init(x: lastXValue, y: lastUpstreamValue.y))
      }

      let xValueSubscription = xValueStream.subscribeToValue { value in
        lastXValue = value
        checkAndEmit()
      }

      let upstreamSubscription = self.subscribeAndForward(to: observer) { value in
        lastUpstreamValue = value
        checkAndEmit()
      }

      return {
        upstreamSubscription.unsubscribe()
        xValueSubscription.unsubscribe()
      }
    }
  }
}
