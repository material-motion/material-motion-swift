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
import UIKit

/**
 The possible configurations of a "set position on tap" interaction.
 */
public enum SetPositionOnTapConfiguration {
  /**
   When the interaction is added to a view, the interaction will create a new gesture recognizer and
   register it on the runtime's container view.
   */
  case registerNewRecognizerToContainerView

  /**
   When the interaction is added to a view, the interaction will create a new gesture recognizer and
   register it on the given view.
   */
  case registerNewRecognizerTo(UIView)

  /**
   The interaction will make use of the provided gesture recognizer.

   The interaction will not associate this gesture recognizer with any view.
   */
  case withExistingRecognizer(UITapGestureRecognizer)
}

/**
 A "set position on tap" interaction will write a position value to a property every time the
 associated tap gesture recognizer is recognized.

 **Constraints**

 CGPoint constraints may be applied to this interaction.
 */
public final class SetPositionOnTap: Interaction {
  /**
   Creates a new instance with a given configuration and coordinate space.

   - parameter config: Affects how gesture recognizer instances are handled when this interaction is registered to the runtime.
   - parameter coordinateSpace: Defines the coordinate space to which the position is relative.
   */
  public init(_ config: SetPositionOnTapConfiguration = .registerNewRecognizerToContainerView, coordinateSpace: UIView? = nil) {
    self.config = config
    self.coordinateSpace = coordinateSpace
  }

  /**
   The interaction's configuration.
   */
  public let config: SetPositionOnTapConfiguration

  /**
   The position will be relative to this coordinate space.
   */
  public let coordinateSpace: UIView?

  public func add(to property: ReactiveProperty<CGPoint>,
                  withRuntime runtime: MotionRuntime,
                  constraints applyConstraints: ConstraintApplicator<CGPoint>? = nil) {
    let gestureRecognizer: UITapGestureRecognizer

    switch config {
    case .registerNewRecognizerToContainerView:
      gestureRecognizer = UITapGestureRecognizer()
      runtime.containerView.addGestureRecognizer(gestureRecognizer)

    case .registerNewRecognizerTo(let view):
      gestureRecognizer = UITapGestureRecognizer()
      view.addGestureRecognizer(gestureRecognizer)

    case .withExistingRecognizer(let existingGestureRecognizer):
      gestureRecognizer = existingGestureRecognizer
    }

    let coordinateSpace = self.coordinateSpace ?? runtime.containerView

    var stream = runtime.get(gestureRecognizer).centroidOnRecognition(in: coordinateSpace)
    if let applyConstraints = applyConstraints {
      stream = applyConstraints(stream)
    }
    runtime.connect(stream, to: property)
  }
}
