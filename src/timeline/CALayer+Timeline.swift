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

import IndefiniteObservable
import UIKit

extension CALayer {
  private class TimelineInfo {
    var timeline: Timeline?
    var lastState: Timeline.Snapshot?
    var subscription: Subscription?
  }

  private struct AssociatedKeys {
    static var timelineInfo = "MDMTimelineInfo"
  }

  var timeline: Timeline? {
    get { return (objc_getAssociatedObject(self, &AssociatedKeys.timelineInfo) as? TimelineInfo)?.timeline }
    set {
      let timelineInfo = (objc_getAssociatedObject(self, &AssociatedKeys.timelineInfo) as? TimelineInfo) ?? TimelineInfo()
      timelineInfo.timeline = newValue
      objc_setAssociatedObject(self, &AssociatedKeys.timelineInfo, timelineInfo, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

      guard let timeline = timelineInfo.timeline else {
        timelineInfo.subscription = nil
        return
      }

      timelineInfo.subscription = timeline.subscribeToValue { [weak self] state in
        guard let strongSelf = self else { return }
        timelineInfo.lastState = state

        if state.paused {
          strongSelf.speed = 0
          strongSelf.timeOffset = TimeInterval(state.beginTime + state.timeOffset)

        } else if strongSelf.speed == 0 { // Unpause the layer.
          // The following logic is the magic sauce required to reconnect a CALayer with the
          // render server's clock.
          let pausedTime = strongSelf.timeOffset
          strongSelf.speed = 1
          strongSelf.timeOffset = 0
          strongSelf.beginTime = 0
          let timeSincePause = strongSelf.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
          strongSelf.beginTime = timeSincePause
        }
      }
    }
  }

  var lastTimelineState: Timeline.Snapshot? {
    return (objc_getAssociatedObject(self, &AssociatedKeys.timelineInfo) as? TimelineInfo)?.lastState
  }
}
