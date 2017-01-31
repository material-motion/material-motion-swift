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
import pop

// In order to support POP's vector-based properties we create specialized connectPOPSpring methods.
// Each specialized method is expected to read from and write to a POP vector value.

/** Create a pop spring source for a CGFloat Spring plan. */
public func pop(_ spring: Spring<CGFloat>, initialValue: MotionObservable<CGFloat>) -> (MotionObservable<CGFloat>) {
  return MotionObservable { observer in
    let animation = POPSpringAnimation()

    let popProperty = POPMutableAnimatableProperty()
    popProperty.threshold = spring.threshold.value
    popProperty.readBlock = { _, toWrite in
      toWrite![0] = initialValue.read()!
    }
    popProperty.writeBlock = { _, toRead in
      observer.next(toRead![0])
    }
    animation.property = popProperty

    return configureSpringAnimation(animation, spring: spring, initialValue: initialValue, observer: observer)
  }
}

/** Create a pop spring source for a CGPoint Spring plan. */
public func pop(_ spring: Spring<CGPoint>, initialValue: MotionObservable<CGPoint>) -> (MotionObservable<CGPoint>) {
  return MotionObservable { observer in
    let animation = POPSpringAnimation()

    let popProperty = POPMutableAnimatableProperty()
    popProperty.threshold = spring.threshold.value
    popProperty.readBlock = { _, toWrite in
      let value = initialValue.read()!
      toWrite![0] = value.x
      toWrite![1] = value.y
    }
    popProperty.writeBlock = { _, toRead in
      observer.next(CGPoint(x: toRead![0], y: toRead![1]))
    }
    animation.property = popProperty

    return configureSpringAnimation(animation, spring: spring, initialValue: initialValue, observer: observer)
  }
}

private func configureSpringAnimation<T>(_ animation: POPSpringAnimation, spring: Spring<T>, initialValue: MotionObservable<T>, observer: MotionObserver<T>) -> () -> Void {
  animation.dynamicsFriction = spring.friction.value
  animation.dynamicsTension = spring.tension.value

  animation.removedOnCompletion = false
  if let initialVelocity = spring.initialVelocity.read() {
    animation.velocity = initialVelocity
  }

  // animationDidStartBlock is invoked at the turn of the run loop, potentially leaving this stream
  // in an at rest state even though it's effectively active. To ensure that the stream is marked
  // active until the run loop turns we immediately send an .active state to the observer.

  observer.state(.active)

  animation.animationDidStartBlock = { anim in
    observer.state(.active)
  }
  animation.completionBlock = { anim, finished in
    observer.state(.atRest)
  }

  let destinationSubscription = spring.destination.subscribe(next: { value in
    animation.toValue = value
    animation.isPaused = false
  }, state: { _ in }, coreAnimation: { _ in })

  assert(animation.toValue != nil, "No destination value received from destination stream.")

  let key = NSUUID().uuidString
  let someObject = NSObject()
  someObject.pop_add(animation, forKey: key)

  return {
    someObject.pop_removeAnimation(forKey: key)
    destinationSubscription.unsubscribe()
  }
}
