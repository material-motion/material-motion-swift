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
public class DirectlyManipulable: NSObject {
  public let draggable: Draggable
  public let rotatable: Rotatable
  public let scalable: Scalable

  init(draggable: Draggable = Draggable(), rotatable: Rotatable = Rotatable(), scalable: Scalable = Scalable()) {
    self.draggable = draggable
    self.rotatable = rotatable
    self.scalable = scalable
  }
}

extension DirectlyManipulable: Interaction {
  public func add(to view: UIView, withRuntime runtime: MotionRuntime) {
    for gestureRecognizer in [draggable.nextGestureRecognizer,
                              rotatable.nextGestureRecognizer,
                              scalable.nextGestureRecognizer] {
      if gestureRecognizer.delegate == nil {
        gestureRecognizer.delegate = self
      }
    }

    let adjustsAnchorPoint = AdjustsAnchorPoint(gestureRecognizers: [rotatable.nextGestureRecognizer,
                                                                     scalable.nextGestureRecognizer])
    runtime.add(adjustsAnchorPoint, to: view)
    runtime.add(draggable, to: view)
    runtime.add(rotatable, to: view)
    runtime.add(scalable, to: view)
  }
}

extension DirectlyManipulable: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
