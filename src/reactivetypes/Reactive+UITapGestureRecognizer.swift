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

extension Reactive where O: UIGestureRecognizer {

  public var isEnabled: ReactiveProperty<Bool> {
    let gesture = _object
    return _properties.named(#function, onCacheMiss: {
      return ReactiveProperty("\(pretty(gesture)).\(#function)", initialValue: gesture.isEnabled) {
        gesture.isEnabled = $0
      }
    })
  }

  public var didAnything: MotionObservable<O> {
    return _properties.named("recognition", onCacheMiss: {
      return GestureConnection(subscribedTo: _object)
    }, typeConversion: {
      return $0.asStream()
    })
  }

  public var didRecognize: MotionObservable<O> {
    return _properties.named("recognition", onCacheMiss: {
      return GestureConnection(subscribedTo: _object)
    }, typeConversion: {
      return $0.asStream()._filter { $0.state == .recognized }
    })
  }
}

private final class GestureConnection<O: UIGestureRecognizer>: MotionObservableConvertible {
  init(subscribedTo gesture: O) {
    self.gesture = gesture

    gesture.addTarget(self, action: #selector(gestureDidChange))
  }

  func asStream() -> MotionObservable<O> {
    return MotionObservable { observer in
      self.didChangeObservers.append(observer)
      return {
        if let index = self.didChangeObservers.index(where: { $0 === observer }) {
          self.didChangeObservers.remove(at: index)
        }
      }
    }
  }

  @objc private func gestureDidChange(_ gesture: UIGestureRecognizer) {
    didChangeObservers.forEach { $0.next(gesture as! O) }
  }
  private var didChangeObservers: [MotionObserver<O>] = []
  private weak var gesture: O?

  public let metadata = Metadata("Gesture delegate")
}
