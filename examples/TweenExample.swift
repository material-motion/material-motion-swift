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
import IndefiniteObservable
import MaterialMotion

/**
 A tween is an interpolation between two or more values, often making use of a non-linear timing
 function.

 **Constraints**

 T-value constraints may be applied to this interaction.
 */
public class Tween2<T: Subtractable>: Interaction2 {

  public init(for keyPath: CoreAnimationKeyPath<T>) {
    self.keyPath = keyPath
  }

  public func enable() {
    let animation: CAPropertyAnimation
    if values.count > 1 {
      let keyframeAnimation = CAKeyframeAnimation()
      keyframeAnimation.values = values
      keyframeAnimation.keyTimes = keyPositions.map { NSNumber(value: Double($0)) }
      keyframeAnimation.timingFunctions = timingFunctions
      animation = keyframeAnimation
    } else {
      let basicAnimation = CABasicAnimation()
      basicAnimation.toValue = values.last
      basicAnimation.timingFunction = timingFunctions.first
      animation = basicAnimation
    }
    keyPath.property.value = values.last!

    animation.beginTime = CFTimeInterval(delay)
    animation.duration = CFTimeInterval(duration)
    animation.repeatCount = Float(repeatCount)
    animation.repeatDuration = CFTimeInterval(repeatDuration)
    animation.autoreverses = autoreverses

    let key = NSUUID().uuidString
    activeKeys.insert(key)

    keyPath.add(animation, forKey: key)
  }
  var activeKeys = Set<String>()

  public func disable() {
    activeKeys.forEach { keyPath.removeAnimation(forKey: $0) }
    activeKeys.removeAll()
  }

  /**
   The duration of the animation in seconds.
   */
  public var duration: CGFloat = 0

  /**
   The number of times the animation will repeat.

   If the repeatCount is 0, it is ignored. If both repeatDuration and repeatCount are specified the behavior is undefined.

   Setting this property to greatestFiniteMagnitude will cause the animation to repeat forever.

   See https://developer.apple.com/reference/quartzcore/camediatiming/1427666-repeatcount for more information.
   */
  public var repeatCount: CGFloat = 0

  /**
   The number of seconds the animation will repeat for.

   If the repeatDuration is 0, it is ignored. If both repeatDuration and repeatCount are specified the behavior is undefined.

   See https://developer.apple.com/reference/quartzcore/camediatiming/1427643-repeatduration for more information.
   */
  public var repeatDuration: CGFloat = 0

  /**
   Will the animation play in the reverse upon completion.

   See https://developer.apple.com/reference/quartzcore/camediatiming/1427645-autoreverses for more information.
   */
  public var autoreverses: Bool = false

  /**
   The delay of the animation in seconds.
   */
  public var delay: CGFloat = 0

  /**
   An array of objects providing the value of the animation for each keyframe.

   If values.count == 1 then the sole value will be treated as the toValue in a basic animation.

   See CAKeyframeAnimation documentation for more details.
   */
  public var values: [T] = []

  /**
   An array of number values defining the pacing of the animation.

   Each position corresponds to one value in the `values' array, and defines when the value should
   be used in the animation function. Each value in the array is a floating point number in the
   range [0,1].

   See CAKeyframeAnimation documentation for more details.
   */
  public var keyPositions: [CGFloat] = []

  /**
   An array of CAMediaTimingFunction objects. If the `values' array defines n keyframes,
   there should be n-1 objects in the `timingFunctions' array. Each function describes the pacing of
   one keyframe to keyframe segment.

   If values.count == 1 then a single timing function may be provided to configure the basic
   animation.

   See CAKeyframeAnimation documentation for more details.
   */
  public var timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]

  /**
   An optional timeline that may scrub this tween animation.

   If provided, this tween is expected to be timed in relation to the timeline's beginTime.
   */
  public var timeline: Timeline? = nil

  let keyPath: CoreAnimationKeyPath<T>
}

class TweenExampleViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = center(createExampleView(), within: view)
    view.addSubview(square)

    let tween = Tween2(for: Reactive(square.layer).opacityKeyPath)
    tween.duration = 1
    tween.values = [1, 0, 1]

    let tap = UITapGestureRecognizer()
    view.addGestureRecognizer(tap)

    Reactive(tap).didRecognize.subscribeToValue { _ in
      tween.enable()
    }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap anywhere to move the view.")
  }
}
