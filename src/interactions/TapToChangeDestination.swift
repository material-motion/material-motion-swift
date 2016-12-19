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

/** On tap, changes the destination to the tap's centroid. */
public class TapToChangeDestination: Interaction {
  public let destination: ReactiveProperty<CGPoint>
  public var destinationStream: MotionObservable<CGPoint>

  /**
   - parameter containerView: The tap gesture recognizer's centroid will be calculated relative to
                              this view. If the tap gesture recognizer isn't associated with a view
                              already, it will be added to this view.
   - parameter destination: The destination property to which the tap centroid should be written.
   - parameter tapGestureRecognizer: The tap gesture recognizer whose taps should be observed.
   */
  public init(containerView: UIView,
              destination: ReactiveProperty<CGPoint>,
              tapGestureRecognizer: UITapGestureRecognizer? = nil) {
    self.destination = destination

    let tapGestureRecognizer = tapGestureRecognizer ?? UITapGestureRecognizer()
    if tapGestureRecognizer.view == nil {
      containerView.addGestureRecognizer(tapGestureRecognizer)
    }

    self.destinationStream = gestureSource(tapGestureRecognizer)
      .onRecognitionState(.recognized)
      .centroid(in: containerView)
  }

  /**
   A convenience method that creates the destination reactive property for you.

   - parameter containerView: The tap gesture recognizer's centroid will be calculated relative to
                              this view. If the tap gesture recognizer isn't associated with a view
                              already, it will be added to this view.
   - parameter destination: An initial destination value.
   - parameter tapGestureRecognizer: The tap gesture recognizer whose taps should be observed.
   */
  public convenience init(containerView: UIView, destination: CGPoint, tapGestureRecognizer: UITapGestureRecognizer? = nil) {
    self.init(containerView: containerView,
              destination: createProperty(withInitialValue: destination),
              tapGestureRecognizer: tapGestureRecognizer)
  }

  public func connect(with aggregator: MotionAggregator) {
    aggregator.write(destinationStream, to: destination)
  }
}
