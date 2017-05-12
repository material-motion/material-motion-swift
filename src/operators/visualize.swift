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
import UIKit

extension MotionObservableConvertible {

  /**
   Adds a visualization label to the given view, updates the label as values are received, and emits
   the unmodified value.

   The label is added to the bottom of the given view. The view's frame is expanded to accomodate
   the new label and the frame is shifted up by a corresponding amount.

   The label's background will flash white whenever the values change.

   This operator assumes that the label will be added to a MotionRuntime's `visualizationView`.
   */
  public func visualize(_ prefix: String? = nil, in view: UIView) -> MotionObservable<T> {
    return MotionObservable<T> { observer in
      let label = UILabel()
      let highlight = UIView()
      highlight.backgroundColor = .white
      highlight.alpha = 0

      let topEdge: CGFloat
      if let lastView = view.subviews.last {
        topEdge = lastView.frame.maxY
      } else {
        topEdge = 0
      }
      label.frame = .init(x: 0, y: topEdge, width: view.bounds.width, height: label.font.lineHeight)
      highlight.frame = label.frame
      var frame = view.frame
      frame.size.height += label.frame.height
      frame.origin.y -= label.frame.height
      view.frame = frame
      view.addSubview(highlight)
      view.addSubview(label)

      let subscription = self.asStream().subscribeAndForward(to: observer) { value in
        let stringValue = String(describing: value)
        let labelText = (prefix ?? "") + stringValue
        if label.text == labelText {
          observer.next(value)
          return
        }

        label.text = labelText

        highlight.alpha = 1
        UIView.animate(withDuration: 0.3) {
          highlight.alpha = 0
        }

        observer.next(value)
      }

      return {
        subscription.unsubscribe()
      }
    }
  }
}
