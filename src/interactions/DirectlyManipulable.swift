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
 Allows a view to be directly manipulated with a combination of pan, rotation, and scale gestures.

 Composed of three sub-interactions: Draggable, Rotatable, and Scalable, along with anchor point
 manipulation and resetting.

 The provided gesture recognizers must be configured to enable simultaneous recognition.
 */
public class DirectlyManipulable: Interaction {

  /** The draggable interaction. */
  public let draggable: Draggable

  /** The rotatable interaction. */
  public let rotatable: Rotatable

  /** The scalable interaction. */
  public let scalable: Scalable

  public var anchorPointStreams: [MotionObservable<CGPoint>]
  public var anchorPointResetStreams: [MotionObservable<CGPoint>]

  /**
   - parameter view: The view that should be made directly manipulable.
   - parameter containerView: Translation will be calculated relative to this view. If any gesture
                              recognizer isn't associated with a view already, it will be added to
                              this view.
   - parameter panGestureRecognizer: The pan gesture recognizer whose events should be observed.
   - parameter rotationGestureRecognizer: The rotation gesture recognizer whose events should be
                                          observed.
   - parameter scaleGestureRecognizer: The scale gesture recognizer whose events should be observed.
   */
  public init(view: UIView,
              containerView: UIView,
              panGestureRecognizer: UIPanGestureRecognizer? = nil,
              rotationGestureRecognizer: UIRotationGestureRecognizer? = nil,
              scaleGestureRecognizer: UIPinchGestureRecognizer? = nil) {
    self.draggable = Draggable(view: view,
                               containerView: containerView,
                               gestureRecognizer: panGestureRecognizer)
    self.rotatable = Rotatable(view: view,
                               containerView: containerView,
                               gestureRecognizer: rotationGestureRecognizer)
    self.scalable = Scalable(view: view,
                             containerView: containerView,
                             gestureRecognizer: scaleGestureRecognizer)
    self.anchorPoint = propertyOf(view.layer).anchorPoint()

    let gestureStreams = [draggable.gestureRecognizer, rotatable.gestureRecognizer, scalable.gestureRecognizer]
    anchorPointStreams = gestureStreams.map {
      gestureSource($0).onRecognitionState(.began).centroid(in: view).normalized(by: view.bounds.size)
    }
    anchorPointResetStreams = gestureStreams.map {
      gestureSource($0).onRecognitionStates([.ended, .cancelled]).constant(CGPoint(x: 0.5, y: 0.5))
    }
  }

  public func connect(with runtime: MotionRuntime) {
    anchorPointResetStreams.forEach {
      runtime.write($0, to: anchorPoint)
    }
    anchorPointStreams.forEach {
      runtime.write($0, to: anchorPoint)
    }

    draggable.connect(with: runtime)
    rotatable.connect(with: runtime)
    scalable.connect(with: runtime)
  }

  private let anchorPoint: ReactiveProperty<CGPoint>
}
