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
 Attaches a position to a destination using a spring while allowing it to be dragged and tossed.

 Initiating a drag will stop the spring simulation.
 */
public class TossableAndAttachWithSpring: AttachWithSpring<CGPoint> {

  /** A stream that emits the pan gesture's velocity when the gesture ends. */
  public var initialVelocityStream: MotionObservable<CGPoint>

  /**
   - parameter position: The position to be updated by the position stream.
   - parameter destination: The destination property to which the position should spring.
   - parameter containerView: The container view within which the pan gesture recognizer's
                              translation and velocity are calculated.
   - parameter springSource: A function capable of creating a spring source.
   - parameter panGestureRecognizer: The pan gesture recognizer whose taps should be observed.
                                     If not provided, one will be created for you.
   */
  public init(position: ReactiveProperty<CGPoint>,
              to destination: ReactiveProperty<CGPoint>,
              containerView: UIView,
              springSource: SpringSource<CGPoint>,
              panGestureRecognizer: UIPanGestureRecognizer? = nil) {
    let panGestureRecognizer = panGestureRecognizer ?? UIPanGestureRecognizer()
    if panGestureRecognizer.view == nil {
      containerView.addGestureRecognizer(panGestureRecognizer)
    }

    let dragStream = gestureSource(panGestureRecognizer)
    let translationStream = dragStream.translated(from: position.stream, in: containerView)

    self.initialVelocityStream = dragStream.onRecognitionState(.ended).velocity(in: containerView)

    super.init(property: position, to: destination, threshold: 1, springSource: springSource)

    self.valueStream = self.valueStream.toggled(with: translationStream)
  }

  public override func connect(with runtime: MotionRuntime) {
    runtime.write(initialVelocityStream, to: spring.initialVelocity)

    super.connect(with: runtime)
  }
}
