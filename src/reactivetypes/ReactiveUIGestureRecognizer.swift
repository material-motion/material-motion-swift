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

public class ReactiveUIGestureRecognizer<O: UIGestureRecognizer>: Stateful {
  public let gestureRecognizer: O

  public lazy var isEnabled: ReactiveProperty<Bool> = {
    let gestureRecognizer = self.gestureRecognizer
    return ReactiveProperty(#function,
                            initialValue: gestureRecognizer.isEnabled,
                            externalWrite: { gestureRecognizer.isEnabled = $0 })
  }()

  init(_ gestureRecognizer: O, containerView: UIView) {
    self.gestureRecognizer = gestureRecognizer
    self.containerView = containerView
    self.stream = gestureToStream(gestureRecognizer)
  }

  public let metadata = Metadata("Gesture Recognizer")

  public var state: MotionObservable<MotionState> {
    return asStream().asMotionState()
  }

  fileprivate let containerView: UIView
  fileprivate let stream: MotionObservable<O>
}

extension ReactiveUIGestureRecognizer: MotionObservableConvertible {
  public func asStream() -> MotionObservable<O> {
    return stream
  }
}

extension ReactiveUIGestureRecognizer {
  public func centroidOnRecognition(in relativeView: UIView) -> MotionObservable<CGPoint> {
    return stream.whenRecognitionState(is: .recognized).centroid(in: relativeView)
  }
}

extension ReactiveUIGestureRecognizer where O: UIPanGestureRecognizer {

  public func translation<O: MotionObservableConvertible>(addedTo initialPosition: O) -> MotionObservable<CGPoint> where O.T == CGPoint {
    return stream.whenRecognitionState(isAnyOf: [.began, .changed]).translation(addedTo: initialPosition, in: containerView)
  }
  public func velocityOnReleaseStream() -> MotionObservable<CGPoint> {
    return stream.whenRecognitionState(is: .ended).velocity(in: containerView)
  }
  public func velocityOnReleaseStream(in relativeView: UIView) -> MotionObservable<CGPoint> {
    return stream.whenRecognitionState(is: .ended).velocity(in: relativeView)
  }
}

extension ReactiveUIGestureRecognizer where O: UIRotationGestureRecognizer {
  public func velocityOnReleaseStream() -> MotionObservable<CGFloat> {
    return stream.whenRecognitionState(is: .ended).velocity()
  }
}

extension ReactiveUIGestureRecognizer where O: UIPinchGestureRecognizer {
  public func velocityOnReleaseStream() -> MotionObservable<CGFloat> {
    return stream.whenRecognitionState(is: .ended).velocity()
  }
}
