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

/**
 A UIScrollViewDelegate implementation that exposes observable streams for the scroll view delegate
 events.

 Supported events:

 - scrollViewDidScroll:

 The canonical stream will emit the contentOffset each time a scrollViewDidScroll event is received.
 */
public final class ReactiveGestureTarget<O: UIGestureRecognizer> {

  public init() {
  }

  public var didChange: MotionObservable<O> {
    return MotionObservable { observer in
      self.didChangeObservers.append(observer)
      return {
        if let index = self.didChangeObservers.index(where: { $0 === observer }) {
          self.didChangeObservers.remove(at: index)
        }
      }
    }
  }

  @objc public func gestureDidChange(_ gesture: UIGestureRecognizer) {
    didChangeObservers.forEach { $0.next(gesture as! O) }
  }
  private var didChangeObservers: [MotionObserver<O>] = []
}
