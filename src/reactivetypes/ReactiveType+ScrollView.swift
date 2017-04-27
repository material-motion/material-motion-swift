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

public func reactive(_ object: UIScrollView) -> ReactiveScrollView {
  return ReactiveScrollView(object)
}

extension Reactive where O: UIScrollView {

  public var contentOffset: ReactiveProperty<CGPoint> {
    let view = _object

    // TODO: There should be a type of property that can automatically hook in to KVO for
    // bi-directional observation. Should register to KVO only when at least one observer is
    // subscribed.

    return _properties.named(#function) {
      return .init("\(pretty(view)).\(#function)", initialValue: view.contentOffset) {
        view.contentOffset = $0
      }
    }
  }
}

public final class ReactiveScrollView: Reactive<UIScrollView>, MotionObservableConvertible {
  public override init(_ scrollView: UIScrollView) {
    self.observer = ScrollViewObserver(subscribedTo: scrollView)

    super.init(scrollView)
  }

  public let metadata = Metadata("Gesture Recognizer")

  public func asStream() -> MotionObservable<CGPoint> {
    let scrollViewObserver = self.observer
    return MotionObservable(Metadata("Scroll View", args: [_object])) { observer in
      scrollViewObserver.addObserver(observer)
      return {
        scrollViewObserver.removeObserver(observer)
      }
    }
  }

  private let observer: ScrollViewObserver
}

private final class ScrollViewObserver: NSObject {
  deinit {
    scrollView.removeObserver(self,
                              forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)),
                              context: &scrollViewConnectionContext)
  }

  init(subscribedTo scrollView: UIScrollView) {
    self.scrollView = scrollView

    super.init()

    scrollView.addObserver(self,
                           forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)),
                           options: .new,
                           context: &scrollViewConnectionContext)
  }

  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if context == &scrollViewConnectionContext {
      if let newValue = change?[.newKey] as? CGPoint {
        observers.forEach { $0.next(newValue) }
      }

    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  func addObserver(_ observer: MotionObserver<CGPoint>) {
    observer.next(scrollView.contentOffset)
    observers.append(observer)
  }

  func removeObserver(_ observer: MotionObserver<CGPoint>) {
    if let index = observers.index(where: { $0 === observer }) {
      observers.remove(at: index)
    }
  }

  private var observers: [MotionObserver<CGPoint>] = []
  private let scrollView: UIScrollView
}

// See the Apple developer documentation on implementing KVO in swift.
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html#//apple_ref/doc/uid/TP40014216-CH7-ID12
private var scrollViewConnectionContext = 0
