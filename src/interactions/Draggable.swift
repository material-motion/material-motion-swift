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

/**
 Modifies a position in reaction to a pan gesture recognizer's translation.

 Will add the gesture recognizer's translation to the property's initial value.
 */
public class Draggable: Interaction {
  /** The property to which the value stream is expected to write. */
  public let property: ReactiveProperty<CGPoint>

  /** A stream that emits values to be written to the property. */
  public var valueStream: MotionObservable<CGPoint>

  /** A stream that emits velocity when the gesture recognizer ends. */
  public var velocityStream: MotionObservable<CGPoint>

  /** The gesture recognizer that drives this interaction. */
  public let gestureRecognizer: UIPanGestureRecognizer

  /**
   - parameter property: The property to be updated by the value stream.
   - parameter containerView: The gesture recognizer's translation will be calculated relative to
                              this view. If the gesture recognizer isn't associated with a view
                              already, it will be added to this view.
   - parameter gestureRecognizer: The gesture recognizer whose events should be observed.
   */
  public init(property: ReactiveProperty<CGPoint>,
              containerView: UIView,
              gestureRecognizer: UIPanGestureRecognizer? = nil) {
    self.property = property

    self.gestureRecognizer = gestureRecognizer ?? UIPanGestureRecognizer()
    if self.gestureRecognizer.view == nil {
      containerView.addGestureRecognizer(self.gestureRecognizer)
    }
    let source = gestureSource(self.gestureRecognizer)
    self.valueStream = source.translated(from: property.stream, in: containerView)
    self.velocityStream = source.velocity(in: containerView)
  }

  /**
   - parameter view: The view whose position should be updated in reaction to the gesture
                     recognizer.
   - parameter containerView: The gesture recognizer's translation will be calculated relative to
                              this view. If the gesture recognizer isn't associated with a view
                              already, it will be added to this view.
   - parameter gestureRecognizer: The gesture recognizer whose events should be observed.
   */
  public convenience init(view: UIView,
                          containerView: UIView,
                          gestureRecognizer: UIPanGestureRecognizer? = nil) {
    self.init(property: propertyOf(view.layer).position(),
              containerView: containerView,
              gestureRecognizer: gestureRecognizer)
  }

  public func connect(with runtime: MotionRuntime) {
    runtime.write(valueStream, to: property)
  }
}
