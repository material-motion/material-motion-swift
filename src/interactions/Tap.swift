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

/** Writes the tap's centroid to the position. */
public class Tap: Interaction {

  /** The position to which the position stream is expected to write. */
  public let position: ReactiveProperty<CGPoint>

  /** A stream that emits positional values to be written to the view. */
  public var positionStream: MotionObservable<CGPoint>

  /**
   - parameter position: The position property to which the tap centroid should be written.
   - parameter containerView: The tap gesture recognizer's centroid will be calculated relative to
                              this view. If the tap gesture recognizer isn't associated with a view
                              already, it will be added to this view.
   - parameter tapGestureRecognizer: The tap gesture recognizer whose taps should be observed.
   */
  public init(sets position: ReactiveProperty<CGPoint>,
              containerView: UIView,
              tapGestureRecognizer: UITapGestureRecognizer? = nil) {
    self.position = position

    let tapGestureRecognizer = tapGestureRecognizer ?? UITapGestureRecognizer()
    if tapGestureRecognizer.view == nil {
      containerView.addGestureRecognizer(tapGestureRecognizer)
    }

    self.positionStream = gestureSource(tapGestureRecognizer)
      .onRecognitionState(.recognized)
      .centroid(in: containerView)
  }

  public func connect(with runtime: MotionRuntime) {
    runtime.write(positionStream, to: position)
  }
}
