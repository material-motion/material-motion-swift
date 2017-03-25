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

extension MotionObservableConvertible {

  /**
   A valve creates control flow for a stream.

   The upstream will be subscribed to when valveStream emits true, and the subscription terminated
   when the valveStream emits false.
   */
  public func valve<O: MotionObservableConvertible>(openWhenTrue valveStream: O) -> MotionObservable<T> where O.T == Bool {
    return MotionObservable<T>(Metadata(#function, args: [valveStream])) { observer in
      var upstreamSubscription: Subscription?

      let valveSubscription = valveStream.subscribeToValue { shouldOpen in
        if shouldOpen && upstreamSubscription == nil {
          upstreamSubscription = self.asStream().subscribeAndForward(to: observer)
        }

        if !shouldOpen && upstreamSubscription != nil {
          upstreamSubscription?.unsubscribe()
          upstreamSubscription = nil
        }
      }

      return {
        valveSubscription.unsubscribe()
        upstreamSubscription?.unsubscribe()
        upstreamSubscription = nil
      }
    }
  }
}
