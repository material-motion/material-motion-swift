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

/**
 Creates a scroll source backed by KVO on a UIScrollView.

 This scroll source will not emit state updates.
 */
func scrollViewToStream(_ scrollView: UIScrollView) -> MotionObservable<CGPoint> {
  return MotionObservable(Metadata("Scroll View", args: [scrollView])) { observer in
    return ScrollViewConnection(subscribedTo: scrollView, observer: observer).disconnect
  }
}

// See the Apple developer documentation on implementing KVO in swift.
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html#//apple_ref/doc/uid/TP40014216-CH7-ID12
private var scrollViewConnectionContext = 0

private final class ScrollViewConnection: NSObject {
  deinit {
    disconnect()
  }

  init(subscribedTo scrollView: UIScrollView, observer: MotionObserver<CGPoint>) {
    self.scrollView = scrollView
    self.observer = observer

    super.init()

    scrollView.addObserver(self,
                           forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)),
                           options: .new,
                           context: &scrollViewConnectionContext)

    observer.next(scrollView.contentOffset)
  }

  func disconnect() {
    scrollView?.removeObserver(self,
                               forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)),
                               context: &scrollViewConnectionContext)
    scrollView = nil
  }

  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if context == &scrollViewConnectionContext {
      if let newValue = change?[.newKey] as? CGPoint {
        observer.next(newValue)
      }

    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  private var scrollView: UIScrollView?
  private let observer: MotionObserver<CGPoint>
}
