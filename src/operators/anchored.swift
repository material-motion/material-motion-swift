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

extension MotionObservableConvertible where T == CGPoint {

  /**
   Emits the incoming anchor point and the position of that anchor point in relation to the given
   view as a pair.

   The resulting stream is multicast so that it's possible to write both values to a layer's
   anchorPoint and position properties, respectively.
   */
  public func anchored(in view: UIView) -> MotionObservable<(CGPoint, CGPoint)> {
    return asStream()._map {
      let newPosition = CGPoint(x: $0.x * view.layer.bounds.width, y: $0.y * view.layer.bounds.height)
      let positionInSuperview = view.layer.convert(newPosition, to: view.layer.superlayer)
      return ($0, positionInSuperview)
    }.multicast()
  }
}
