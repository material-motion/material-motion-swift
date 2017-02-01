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

extension MotionObservableConvertible where T: UIGestureRecognizer {

  /**
   Only emits gesture recognizer events when the gesture recognizer begins with its centroid hitting
   the provided view.

   State is reset when the gesture recognizer ends or cancels.
   */
  public func filter(whenStartsWithin view: UIView) -> MotionObservable<T> {
    var isHit = false
    return asStream()._filter { gesture in
      if gesture.state == .began {
        let location = gesture.location(in: gesture.view!)
        let hitView = gesture.view!.hitTest(location, with: nil)
        isHit = hitView == view
      } else if gesture.state == .ended || gesture.state == .cancelled {
        isHit = false
      }
      return isHit
    }
  }
}
