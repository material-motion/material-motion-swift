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

/**
 Modifies the anchor point of a view when any of the provided gesture recognizers begin.

 **Affected properties**

 - `view.layer.anchorPoint`
 - `view.layer.position`
 */
public final class AdjustsAnchorPoint: Interaction {
  /**
   The gesture recognizers that will be observed.
   */
  let gestureRecognizers: [UIGestureRecognizer]

  /**
   Creates a new anchor point adjustment interaction with the provided gesture recognizers.

   - parameter gestureRecognizers: The gesture recognizers to be observed.
   */
  init<S: Sequence>(gestureRecognizers: S) where S.Iterator.Element: UIGestureRecognizer {
    self.gestureRecognizers = Array(gestureRecognizers)
  }

  public func add(to view: UIView, withRuntime runtime: MotionRuntime, constraints: NoConstraints) {
    var anchorPointStreams = gestureRecognizers.map {
      runtime.get($0)
        .whenRecognitionState(is: .began)
        .centroid(in: view)
        .normalized(by: view.bounds.size)
        .anchorPointAdjustment(in: view)
    }
    anchorPointStreams.append(contentsOf: gestureRecognizers.map {
      runtime.get($0)
        .whenRecognitionState(isAnyOf: [.ended, .cancelled])
        .rewriteTo(CGPoint(x: 0.5, y: 0.5))
        .anchorPointAdjustment(in: view)
    })

    for stream in anchorPointStreams {
      runtime.connect(stream, to: runtime.get(view.layer).anchorPointAdjustment)
    }
  }
}
