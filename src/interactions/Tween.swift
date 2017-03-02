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
public final class Tween<T>: PropertyInteraction, TogglableInteraction, StatefulInteraction {

  /** The duration of the animation in seconds. */
  public let duration: ReactiveProperty<CGFloat>

  /** The delay of the animation in seconds. */
  public let delay = createProperty("Tween.delay", withInitialValue: CGFloat(0))

  /**
   An array of objects providing the value of the animation for each keyframe.

   If values.count == 1 then the sole value will be treated as the toValue in a basic animation.

   See CAKeyframeAnimation documentation for more details.
   */
  public let values: ReactiveProperty<[T]>

  /**
   An array of double values defining the pacing of the animation.

   Each position corresponds to one value in the `values' array, and defines when the value should
   be used in the animation function. Each value in the array is a floating point number in the
   range [0,1].

   See CAKeyframeAnimation documentation for more details.
   */
  public let keyPositions: ReactiveProperty<[CGFloat]> = createProperty("Tween.keyPositions", withInitialValue: [])

  /**
   An array of CAMediaTimingFunction objects. If the `values' array defines n keyframes,
   there should be n-1 objects in the `timingFunctions' array. Each function describes the pacing of
   one keyframe to keyframe segment.

   If values.count == 1 then a single timing function may be provided to configure the basic
   animation.

   See CAKeyframeAnimation documentation for more details.
   */
  public let timingFunctions: ReactiveProperty<[CAMediaTimingFunction]> =
    createProperty("Tween.timingFunctions",
                   withInitialValue: [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)])

  /**
   An optional timeline that may scrub this tween animation.

   If provided, this tween is expected to be timed in relation to the timeline's beginTime.
   */
  public let timeline: Timeline?

  public let enabled = createProperty("Tween.enabled", withInitialValue: true)

  public var state: MotionObservable<MotionState> {
    return _state.asStream()
  }

  public let metadata = Metadata("Tween")

  /** Initializes a tween instance with its required properties. */
  public init(duration: CGFloat, values: [T], system: @escaping TweenToStream<T>, timeline: Timeline? = nil) {
    self.duration = createProperty("Tween.duration", withInitialValue: duration)
    self.values = createProperty("Tween.values", withInitialValue: values)
    self.system = system
    self.timeline = timeline
  }

  public func add(to property: ReactiveProperty<T>, withRuntime runtime: MotionRuntime) {
    runtime.add(asStream(), to: property)
  }

  fileprivate let system: TweenToStream<T>
  fileprivate var stream: MotionObservable<T>?
  fileprivate let _state = createProperty("Tween._state", withInitialValue: MotionState.atRest)
}

public struct TweenShadow<T> {
  public let enabled: ReactiveProperty<Bool>
  public let state: ReactiveProperty<MotionState>
  public let duration: ReactiveProperty<CGFloat>
  public let delay: ReactiveProperty<CGFloat>
  public let values: ReactiveProperty<[T]>
  public let keyPositions: ReactiveProperty<[CGFloat]>
  public let timingFunctions: ReactiveProperty<[CAMediaTimingFunction]>
  public let timeline: Timeline?

  init(of tween: Tween<T>) {
    self.enabled = tween.enabled
    self.state = tween._state
    self.duration = tween.duration
    self.delay = tween.delay
    self.values = tween.values
    self.keyPositions = tween.keyPositions
    self.timingFunctions = tween.timingFunctions
    self.timeline = tween.timeline
  }
}

extension Tween: MotionObservableConvertible {
  public func asStream() -> MotionObservable<T> {
    if stream == nil {
      stream = system(TweenShadow(of: self))._remember()
    }
    return stream!
  }
}
