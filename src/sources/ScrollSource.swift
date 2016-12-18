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

import UIKit

/** A ScrollSource is a function that creates a MotionObservable from a UIScrollView. */
public typealias ScrollSource = (UIScrollView) -> MotionObservable<CGPoint>

public func scrollSource(_ scrollView: UIScrollView) -> MotionObservable<CGPoint> {
  return MotionObservable { observer in
    return ScrollViewConnection(subscribedTo: scrollView, observer: observer).disconnect
  }
}

private var scrollViewConnectionContext = 0

private final class ScrollViewConnection: NSObject {
  deinit {
    self.disconnect()
  }

  init(subscribedTo scrollView: UIScrollView, observer: MotionObserver<CGPoint>) {
    self.scrollView = scrollView
    self.observer = observer

    super.init()

    scrollView.addObserver(self,
                           forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)),
                           options: .new,
                           context: &scrollViewConnectionContext)

    propagate(scrollView)
  }

  func disconnect() {
    scrollView?.removeObserver(self,
                               forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)),
                               context: &scrollViewConnectionContext)
    scrollView = nil
  }

  private func propagate(_ scrollView: UIScrollView) {
    observer.next(scrollView.contentOffset)
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
