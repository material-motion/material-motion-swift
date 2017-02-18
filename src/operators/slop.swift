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

extension MotionObservableConvertible where T == CGFloat {

  /**
   Emits values in reaction to exiting a slop region.

   The slop region is centered around 0 and has the given size. This operator will not emit any
   values until the upstream value exits this slop region, at which point the onExit value will be
   emitted. If the upstream returns to the slop region then onReturn will be emitted.
   */
  public func slop<U: Equatable>(size: CGFloat, onExit: U?, onReturn: U?) -> MotionObservable<U> {
    let didLeaveSlopRegion = createProperty("slop.didLeaveSlopRegion", withInitialValue: false)

    return MotionObservable(self.metadata.createChild(Metadata("\(#function)", type: .constraint, args: [size, onExit, onReturn]))) { observer in
      let upstreamSubscription = self
        .threshold(min: -size, max: size,
                   whenBelow: true, whenWithin: nil as Bool?, whenAbove: true)
        .dedupe()
        .subscribe { didLeaveSlopRegion.value = $0 }

      let downstreamSubscription = self
        .valve(openWhenTrue: didLeaveSlopRegion)
        .threshold(min: -size, max: size,
                   whenBelow: onExit, whenWithin: onReturn, whenAbove: onExit)
        .dedupe()
        .subscribe(next: observer.next, coreAnimation: observer.coreAnimation)

      return {
        upstreamSubscription.unsubscribe()
        downstreamSubscription.unsubscribe()
      }
    }
  }
}
