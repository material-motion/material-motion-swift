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
public class DirectlyManipulable: NSObject, ViewInteraction, UIGestureRecognizerDelegate {

  public let draggable: Draggable
  public let rotatable: Rotatable
  public let scalable: Scalable

  init(draggable: Draggable = Draggable(), rotatable: Rotatable = Rotatable(), scalable: Scalable = Scalable()) {
    self.draggable = draggable
    self.rotatable = rotatable
    self.scalable = scalable
  }

  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    for gestureRecognizer in [draggable.nextGestureRecognizer,
                              rotatable.nextGestureRecognizer,
                              scalable.nextGestureRecognizer] {
      if gestureRecognizer.delegate == nil {
        gestureRecognizer.delegate = self
      }
    }

    let adjustsAnchorPoint = AdjustsAnchorPoint(gestureRecognizers: [rotatable.nextGestureRecognizer,
                                                                     scalable.nextGestureRecognizer])
    runtime.add(adjustsAnchorPoint, to: reactiveView)
    runtime.add(draggable, to: reactiveView)
    runtime.add(rotatable, to: reactiveView)
    runtime.add(scalable, to: reactiveView)
  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
