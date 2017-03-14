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

/**
 A slop event is emitted by the slop operator.
 */
public enum SlopEvent {
  /**
   Emitted each time the position leaves the slop region.
   */
  case onExit

  /**
   Emitted each time the position enters the slop region.
   */
  case onReturn
}

extension MotionObservableConvertible where T == CGFloat {

  /**
   Emits slop events in reaction to exiting and re-entering a slop region.

   The slop region is centered around 0 and has the given size. This operator will not emit any
   events until the upstream value exits this slop region, at which point the onExit event will be
   emitted. If the upstream returns to the slop region then onReturn will be emitted.
   */
  public func slop(size: CGFloat) -> MotionObservable<SlopEvent> {
    let didLeaveSlopRegion = createProperty("slop.didLeaveSlopRegion", withInitialValue: false)

    return MotionObservable(self.metadata.createChild(Metadata(#function, type: .constraint, args: [size]))) { observer in
      let upstreamSubscription = self
        .thresholdRange(min: -size, max: size)
        .rewrite([.whenBelow: true, .whenAbove: true])
        .dedupe()
        .subscribeToValue { didLeaveSlopRegion.value = $0 }

      let downstreamSubscription = self
        .valve(openWhenTrue: didLeaveSlopRegion)
        .thresholdRange(min: -size, max: size)
        .rewrite([.whenBelow: .onExit, .whenWithin: .onReturn, .whenAbove: .onExit])
        .dedupe()
        .subscribeAndForward(to: observer)

      return {
        upstreamSubscription.unsubscribe()
        downstreamSubscription.unsubscribe()
      }
    }
  }
}
