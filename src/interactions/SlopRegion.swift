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

import Foundation
import UIKit

/**
 Changes the direction of a transition when the provided pan gesture recognizer moves out of or back
 into a slop region.

 **Constraints**

 Either the x or y axis can be selected. The default axis is y.
 */
public final class SlopRegion: Interaction {
  /**
   The gesture recognizer that will be observed by this interaction.
   */
  public let gesture: UIPanGestureRecognizer

  /**
   The size of the slop region.
   */
  public let size: CGFloat

  public init(withTranslationOf gesture: UIPanGestureRecognizer, size: CGFloat) {
    self.gesture = gesture
    self.size = size
  }

  /**
   The axis to observe.
   */
  public enum Axis {
    /**
     Observes the x axis.
     */
    case x

    /**
     Observes the y axis.
     */
    case y
  }

  public func add(to direction: ReactiveProperty<TransitionDirection>, withRuntime runtime: MotionRuntime, constraints axis: Axis?) {
    let axis = axis ?? .y
    let chooseAxis: (MotionObservable<CGPoint>) -> MotionObservable<CGFloat>
    switch axis {
    case .x:
      chooseAxis = { $0.x() }
    case .y:
      chooseAxis = { $0.y() }
    }

    runtime.connect(chooseAxis(runtime.get(gesture).translation(in: runtime.containerView))
      .slop(size: size).rewrite([.onExit: .backward, .onReturn: .forward]),
                    to: direction)
  }
}
