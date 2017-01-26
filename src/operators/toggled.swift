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
   Toggled emits values from this stream or the provided one, preferring the provided stream while
   it is active.

   Both streams must emit the same type.

   The provided stream will be subscribed to so long as this operator is subscribed to.
   This stream will be unsubscribed when the provided stream is active.
   This stream will be subscribed when the provided stream is at rest.

   We unsubscribe from this stream so it does not perform unnecessary calculations. This works
   well for spring streams where a gesture stream is the preferred stream.
   */
  public func toggled(with preferredStream: MotionObservable<T>) -> MotionObservable<T> {
    return MotionObservable<T> { observer in
      var preferredStreamSubscription: Subscription?
      var originalStreamSubscription: Subscription?

      // If the preferred stream comes to rest, we subscribe to the unpreferred stream.
      // If the preferred stream becomes active, we unsubscribe from the unpreferred stream.
      //
      // Only one stream is allowed to forward to observer.next at a time.

      // We can't guarantee that we'll receive a state update before we receive a next value, so
      // we start in an unknown state.
      var emittingStream = WhichStream.unknown

      preferredStreamSubscription = preferredStream.subscribe(next: { value in
        if emittingStream == .preferred {
          observer.next(value)
        }

      }, state: { state in
        emittingStream = (state == .active) ? .preferred : .original

        if emittingStream == .preferred {
          observer.state(state)
        }

        if state == .atRest && originalStreamSubscription == nil {
          originalStreamSubscription = self.asStream().subscribe(next: observer.next,
                                                                 state: observer.state,
                                                                 coreAnimation: observer.coreAnimation)
        }

        if state == .active {
          originalStreamSubscription?.unsubscribe()
          originalStreamSubscription = nil
        }

      }, coreAnimation: { event in
        if emittingStream == .preferred {
          observer.coreAnimation(event)
        }
      })

      return {
        preferredStreamSubscription?.unsubscribe()
        originalStreamSubscription?.unsubscribe()
      }
    }
  }
}

private enum WhichStream {
  case unknown
  case preferred
  case original
}
