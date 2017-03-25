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
import CoreGraphics
import IndefiniteObservable

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

   To exit the slop region the value must be either less than -size or greater than size.

   - parameter size: The size of the slop region. A negative size will be treated as a positive
                     size.
   */
  public func slop(size: CGFloat) -> MotionObservable<SlopEvent> {
    let didLeaveSlopRegion = createProperty("slop.didLeaveSlopRegion", withInitialValue: false)

    let size = abs(size)

    return MotionObservable(self.metadata.createChild(Metadata(#function, type: .constraint, args: [size]))) { observer in
      let upstreamSubscription = self
        .thresholdRange(min: -size, max: size)
        .rewrite([.below: true, .above: true])
        .dedupe()
        .subscribeToValue { didLeaveSlopRegion.value = $0 }

      let downstreamSubscription = self
        .valve(openWhenTrue: didLeaveSlopRegion)
        .thresholdRange(min: -size, max: size)
        .rewrite([.below: .onExit, .within: .onReturn, .above: .onExit])
        .dedupe()
        .subscribeAndForward(to: observer)

      return {
        upstreamSubscription.unsubscribe()
        downstreamSubscription.unsubscribe()
      }
    }
  }
}
