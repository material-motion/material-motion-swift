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

extension MotionObservableConvertible where T: UIRotationGestureRecognizer {

  /**
   Adds the current translation to the initial position and emits the result while the gesture
   recognizer is active.
   */
  func rotated<O: MotionObservableConvertible>(from initialRotation: O) -> MotionObservable<CGFloat> where O.T == CGFloat {
    var cachedInitialRotation: CGFloat?
    var lastInitialRotation: CGFloat?

    return MotionObservable(metadata.createChild(Metadata(#function, type: .constraint, args: [initialRotation]))) { observer in
      let initialRotationSubscription = initialRotation.subscribeToValue { lastInitialRotation = $0 }

      let upstreamSubscription = self.subscribeAndForward(to: observer) { value in
        if value.state == .began || (value.state == .changed && cachedInitialRotation == nil)  {
          cachedInitialRotation = lastInitialRotation

        } else if value.state != .began && value.state != .changed {
          cachedInitialRotation = nil
        }
        if let cachedInitialRotation = cachedInitialRotation {
          let rotation = value.rotation
          observer.next(cachedInitialRotation + rotation)
        }
      }

      return {
        upstreamSubscription.unsubscribe()
        initialRotationSubscription.unsubscribe()
      }
    }
  }
}
