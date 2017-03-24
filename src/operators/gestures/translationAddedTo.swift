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

extension MotionObservableConvertible where T: UIPanGestureRecognizer {

  /**
   Adds the current translation to the initial position and emits the result while the gesture
   recognizer is active.
   */
  public func translation<O: MotionObservableConvertible>(addedTo initialPosition: O, in view: UIView) -> MotionObservable<CGPoint> where O.T == CGPoint {
    var cachedInitialPosition: CGPoint?
    var lastInitialPosition: CGPoint?

    return MotionObservable(metadata.createChild(Metadata(#function, type: .constraint, args: [initialPosition, view]))) { observer in
      let initialPositionSubscription = initialPosition.subscribeToValue { lastInitialPosition = $0 }

      let upstreamSubscription = self.subscribeAndForward(to: observer) { value in
        if value.state == .began || (value.state == .changed && cachedInitialPosition == nil)  {
          cachedInitialPosition = lastInitialPosition

        } else if value.state != .began && value.state != .changed {
          cachedInitialPosition = nil
        }
        if let cachedInitialPosition = cachedInitialPosition {
          let translation = value.translation(in: view)
          observer.next(CGPoint(x: cachedInitialPosition.x + translation.x,
                                y: cachedInitialPosition.y + translation.y))
        }
      }

      return {
        upstreamSubscription.unsubscribe()
        initialPositionSubscription.unsubscribe()
      }
    }
  }
}
