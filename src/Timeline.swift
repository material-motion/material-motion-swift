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
import IndefiniteObservable
import UIKit

/**
 A timeline makes it possible to pause and scrub interactions.
 */
public final class Timeline {

  /**
   Creates a new timeline instance.
   */
  public init() {}

  /**
   When a timeline is paused, the timeOffset value should be used to interpolate an interaction to
   that specific time offset in relation to the timeline's beginTime.

   Unpausing a timeline should allow all associated interactions to continue progressing in time on
   their own, starting from timeOffset.
   */
  public let paused = createProperty("Timeline.paused", withInitialValue: false)

  /**
   The starting time for all interactions associated with this timeline.
   */
  public let beginTime = CGFloat(CACurrentMediaTime())

  /**
   The time offset that all paused interactions are expected to be locked to.

   Only affects associated interactions if the timeline is paused.
   */
  public let timeOffset = createProperty("Timeline.timeOffset", withInitialValue: 0)

  public let metadata = Metadata("Timeline")
}

extension Timeline: MotionObservableConvertible {
  /**
   A momentary snapshot of a timeline's state to be emitted down the timeline's stream.
   */
  public struct Snapshot {

    /**
     Whether or not the timeline is paused.
     */
    public let paused: Bool

    /**
     The timeline's beginTime.

     All interactions are expected to be timed relative to this time.
     */
    public let beginTime: CGFloat

    /**
     The timeline's offset in relation to its beginTime.
     */
    public let timeOffset: CGFloat
  }

  /**
   Returns a stream representation of the Timeline.
   */
  public func asStream() -> MotionObservable<Snapshot> {
    return MotionObservable(metadata) { observer in
      var paused = self.paused.value
      var timeOffset = self.timeOffset.value

      let pauseSubscription = self.paused.dedupe().subscribeToValue {
        paused = $0
        observer.next(Snapshot(paused: paused, beginTime: self.beginTime, timeOffset: timeOffset))
      }

      let timeOffsetSubscription = self.timeOffset.dedupe().subscribeToValue {
        timeOffset = $0
        observer.next(Snapshot(paused: paused, beginTime: self.beginTime, timeOffset: timeOffset))
      }

      return {
        pauseSubscription.unsubscribe()
        timeOffsetSubscription.unsubscribe()
      }
    }
  }
}
