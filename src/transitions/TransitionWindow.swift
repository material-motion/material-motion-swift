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

/** A transition window represents a reversible interval of time in a bi-directional transition. */
public final class TransitionTimeWindow {

  /** The transition window's duration in time. */
  public let duration: TimeInterval

  /** Initializes a newly-allocated transition window with a duration. */
  public init(duration: TimeInterval) {
    self.duration = duration
  }
}

/**
 A transition window segment defines a specific region within a transition window.

 position and length are expressed in normalized units between the range [0,1].

 The transition window's position + length must never exceed 1.
 */
public struct TransitionTimeWindowSegment {

  /** The position within the transition window. Expressed in the range [0,1]. */
  public let position: CGFloat

  /** The length of the segment within the transition window. Expressed in range [0,1]. */
  public let length: CGFloat

  public func inverted() -> TransitionTimeWindowSegment {
    return TransitionTimeWindowSegment(position: 1 - (position + length), length: length)
  }
}

public let transitionWindowSegmentEpsilon = 0.00001
