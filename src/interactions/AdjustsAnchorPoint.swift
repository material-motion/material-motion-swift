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

public class AdjustsAnchorPoint: ViewInteraction {

  var gestureRecognizers: [UIGestureRecognizer] = []

  convenience init<S: Sequence>(gestureRecognizers: S) where S.Iterator.Element: UIGestureRecognizer {
    self.init()
    self.gestureRecognizers = Array(gestureRecognizers)
  }

  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    let view = reactiveView.view
    var anchorPointStreams = gestureRecognizers.map {
      runtime.get($0)
        .onRecognitionState(.began)
        .centroid(in: view)
        .normalized(by: view.bounds.size)
        .anchored(in: view)
    }
    anchorPointStreams.append(contentsOf: gestureRecognizers.map {
      runtime.get($0)
        .onRecognitionStates([.ended, .cancelled])
        .mapTo(CGPoint(x: 0.5, y: 0.5))
        .anchored(in: view)
    })

    for stream in anchorPointStreams {
      runtime.add(stream, to: reactiveView.reactiveLayer.anchoring)
    }
  }
}
