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

public class ArcMove: ViewInteraction {

  public var duration: TimeInterval
  public var from: MotionObservable<CGPoint>
  public var to: MotionObservable<CGPoint>
  public var system: PathTweenToStream<CGPoint>

  public var timeline: Timeline?

  init<O1: MotionObservableConvertible, O2: MotionObservableConvertible>(duration: TimeInterval, from: O1, to: O2, system: @escaping PathTweenToStream<CGPoint>) where O1.T == CGPoint, O2.T == CGPoint {
    self.duration = duration
    self.from = from.asStream()
    self.to = to.asStream()
    self.system = system
  }

  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    let path = arcMove(from: from, to: to)
    let tween = PathTween(duration: duration, path: path, system: system)
    tween.timeline = timeline
    runtime.add(tween, to: reactiveView.reactiveLayer.position)
  }
}
