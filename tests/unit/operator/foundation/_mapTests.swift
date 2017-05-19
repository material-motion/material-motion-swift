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

import XCTest
import IndefiniteObservable
import MaterialMotion

class _mapTests: XCTestCase {

  func testSubscription() {
    let value = 10
    let scalar = 10

    let observable = MotionObservable<Int> { observer in
      observer.next(value)
      return noopDisconnect
    }

    let valueReceived = expectation(description: "Value was received")
    let _ = observable._map { value in
      return value * scalar

    }.subscribeToValue {
      if $0 == value * scalar {
        valueReceived.fulfill()
      }
    }

    waitForExpectations(timeout: 0)
  }

  func testBasicAnimationMapping() {
    let fromValue = 10
    let toValue = -2
    let byValue = -5
    let scalar = 10

    let observable = MotionObservable<Int> { observer in
      let animation = CABasicAnimation(keyPath: "opacity")
      animation.fromValue = fromValue
      animation.toValue = toValue
      animation.byValue = byValue
      let add = CoreAnimationChannelAdd(animation: animation, key: "a", onCompletion: { })
      observer.coreAnimation?(CoreAnimationChannelEvent.add(add))
      return noopDisconnect
    }

    let eventReceived = expectation(description: "Event was received")
    let _ = observable._map { value in
      return value * scalar

    }.subscribe(next: { _ in }, coreAnimation: { event in
      switch event {
      case .add(let add):
        let animation = add.animation as! CABasicAnimation
        XCTAssertEqual(animation.fromValue as! Int, fromValue * scalar)
        XCTAssertEqual(animation.toValue as! Int, toValue * scalar)
        XCTAssertEqual(animation.byValue as! Int, byValue * scalar)
        eventReceived.fulfill()
      default: ()
      }

    }, visualization: { _ in })

    waitForExpectations(timeout: 0)
  }

  func testKeyframeAnimationMapping() {
    let values = [10, 20, 50]
    let scalar = 10

    let observable = MotionObservable<Int> { observer in
      let animation = CAKeyframeAnimation(keyPath: "opacity")
      animation.values = values
      let add = CoreAnimationChannelAdd(animation: animation, key: "a", onCompletion: { })
      observer.coreAnimation?(CoreAnimationChannelEvent.add(add))
      return noopDisconnect
    }

    let eventReceived = expectation(description: "Event was received")
    let _ = observable._map { value in
      return value * scalar

      }.subscribe(next: { _ in }, coreAnimation: { event in
        switch event {
        case .add(let add):
          let animation = add.animation as! CAKeyframeAnimation
          XCTAssertEqual(values.map { $0 * scalar }, animation.values as! [Int])
          eventReceived.fulfill()
        default: ()
        }

      }, visualization: { _ in })

    waitForExpectations(timeout: 0)
  }

  func testInitialVelocityMapping() {
    let velocity = 10
    let scalar = 10

    let observable = MotionObservable<Int> { observer in
      let animation = CABasicAnimation(keyPath: "opacity")
      var add = CoreAnimationChannelAdd(animation: animation, key: "a", onCompletion: { })
      add.initialVelocity = velocity
      observer.coreAnimation?(CoreAnimationChannelEvent.add(add))
      return noopDisconnect
    }

    let eventReceived = expectation(description: "Event was received")
    let _ = observable._map(transformVelocity: true) { value in
      return value * scalar

      }.subscribe(next: { _ in }, coreAnimation: { event in
        switch event {
        case .add(let add):
          XCTAssertEqual(add.initialVelocity as! Int, velocity * scalar)
          eventReceived.fulfill()
        default: ()
        }

      }, visualization: { _ in })

    waitForExpectations(timeout: 0)
  }

  func testAnimationIsCopied() {
    var originalAnimation: CABasicAnimation?
    let observable = MotionObservable<Int> { observer in
      originalAnimation = CABasicAnimation()
      let add = CoreAnimationChannelAdd(animation: originalAnimation!, key: "a", onCompletion: { })
      observer.coreAnimation?(CoreAnimationChannelEvent.add(add))
      return noopDisconnect
    }

    let eventReceived = expectation(description: "Event was received")
    let _ = observable._map { value in
      return value * 10

      }.subscribe(next: { _ in }, coreAnimation: { event in
        switch event {
        case .add(let add):
          let animation = add.animation as! CABasicAnimation
          XCTAssertNotEqual(originalAnimation, animation)
          eventReceived.fulfill()
        default: ()
        }

      }, visualization: { _ in })

    waitForExpectations(timeout: 0)
  }
}
