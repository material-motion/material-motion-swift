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

/** A tween describes a potential interpolation from one value to another. */
public final class PathTween: PropertyInteraction {

  /** The duration of the animation in seconds. */
  public var duration: MotionObservable<CGFloat>

  /** The delay of the animation in seconds. */
  public var delay: CFTimeInterval = 0

  /** The mode defining this tween's values over time. */
  public let path: MotionObservable<CGPath>

  /**
   An optional timeline that may scrub this tween animation.

   If provided, this tween is expected to be timed in relation to the timeline's beginTime.
   */
  public var timeline: Timeline?

  public let enabled = createProperty(withInitialValue: true)

  public let state = createProperty(withInitialValue: MotionState.atRest)

  public var system: PathTweenToStream<CGPoint>

  /** Initializes a tween instance with its required properties. */
  public init<O: MotionObservableConvertible>(duration: O, path: MotionObservable<CGPath>, system: @escaping PathTweenToStream<CGPoint>) where O.T == CGFloat {
    self.duration = duration.asStream()
    self.path = path
    self.system = system
  }

  public convenience init(duration: CFTimeInterval, path: MotionObservable<CGPath>, system: @escaping PathTweenToStream<CGPoint>) {
    self.init(duration: createProperty(withInitialValue: CGFloat(duration)), path: path, system: system)
  }

  public func add(to property: ReactiveProperty<CGPoint>, withRuntime runtime: MotionRuntime) {
    runtime.add(asStream(), to: property)
  }
}

extension PathTween: MotionObservableConvertible {
  public func asStream() -> MotionObservable<CGPoint> {
    return system(self)
  }
}
