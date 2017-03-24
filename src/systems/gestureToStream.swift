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

/** Create a gesture source that will connect to the provided gesture recognizer. */
func gestureToStream<T: UIGestureRecognizer>(_ gesture: T) -> MotionObservable<T> {
  return MotionObservable(Metadata("Gesture Recognizer", args: [gesture])) { observer in
    return GestureConnection(subscribedTo: gesture, observer: observer).disconnect
  }
}

private final class GestureConnection<T: UIGestureRecognizer> {
  init(subscribedTo gesture: T, observer: MotionObserver<T>) {
    self.gesture = gesture
    self.observer = observer

    gesture.addTarget(self, action: #selector(gestureEvent))

    // Populate the observer with the current gesture state.
    propagate(gesture)
  }

  func disconnect() {
    gesture?.removeTarget(self, action: #selector(gestureEvent))
    gesture = nil
  }

  @objc private func gestureEvent(gesture: UIGestureRecognizer) {
    propagate(gesture)
  }

  private func propagate(_ gesture: UIGestureRecognizer) {
    observer.next(gesture as! T)
  }

  private var gesture: (T)?
  private let observer: MotionObserver<T>
}
