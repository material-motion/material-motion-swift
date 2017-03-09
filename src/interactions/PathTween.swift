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
public final class PathTween: TogglableInteraction, StatefulInteraction {

  /** The duration of the animation in seconds. */
  public let duration: ReactiveProperty<CGFloat>

  /** The delay of the animation in seconds. */
  public let delay = createProperty("PathTween.delay", withInitialValue: CGFloat(0))

  /** The mode defining this tween's values over time. */
  public let path: ReactiveProperty<CGPath>

  /**
   An optional timeline that may scrub this tween animation.

   If provided, this tween is expected to be timed in relation to the timeline's beginTime.
   */
  public let timeline: Timeline?

  public let enabled = createProperty("PathTween.enabled", withInitialValue: true)

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }

  public init(duration: CGFloat, path: CGPath, system: @escaping PathTweenToStream<CGPoint>, timeline: Timeline? = nil) {
    self.duration = createProperty("PathTween.duration", withInitialValue: CGFloat(duration))
    self.path = createProperty("PathTween.path", withInitialValue: path)
    self.system = system
    self.timeline = timeline
  }

  public init(system: @escaping PathTweenToStream<CGPoint>, timeline: Timeline? = nil) {
    self.duration = createProperty("PathTween.duration", withInitialValue: CGFloat(0))
    self.path = createProperty("PathTween.path", withInitialValue: UIBezierPath().cgPath)
    self.system = system
    self.timeline = timeline
  }

  public let metadata = Metadata("Path Tween")

  fileprivate var stream: MotionObservable<CGPoint>?
  fileprivate let system: PathTweenToStream<CGPoint>
  fileprivate let _state = createProperty("PathTween._state", withInitialValue: MotionState.atRest)
}

extension PathTween: Interaction {
  public func add(to property: ReactiveProperty<CGPoint>, withRuntime runtime: MotionRuntime) {
    runtime.connect(asStream(), to: property)
  }
}

public struct PathTweenShadow {
  public let enabled: ReactiveProperty<Bool>
  public let state: ReactiveProperty<MotionState>
  public let duration: ReactiveProperty<CGFloat>
  public let delay: ReactiveProperty<CGFloat>
  public let path: ReactiveProperty<CGPath>
  public let timeline: Timeline?

  init(of tween: PathTween) {
    self.enabled = tween.enabled
    self.state = tween._state
    self.duration = tween.duration
    self.delay = tween.delay
    self.path = tween.path
    self.timeline = tween.timeline
  }
}

extension PathTween: MotionObservableConvertible {
  public func asStream() -> MotionObservable<CGPoint> {
    if stream == nil {
      stream = system(PathTweenShadow(of: self))._remember()
    }
    return stream!
  }
}
