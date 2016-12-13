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
import CoreGraphics
import IndefiniteObservable
@testable import MaterialMotionStreams

enum WhichStream {
  case stream
  case preferredStream
}

class toggleTests: XCTestCase {

  // State diagram:
  // The only time stream will emit values is when stream is active and preferred is at rest.
  //
  //                       preferred state
  //
  //                     active     at rest
  //                  /-----------|---------|
  // stream    active | preferred | stream  |
  //  state   at rest | preferred | stream  |

  // stream active / preferred stream active
  func testEmitsPreferredStreamWhenBothActive() {
    let stream = MotionObservable<WhichStream> { observer in
      observer.state(.active)
      observer.next(.stream)
      return noopDisconnect
    }

    let preferredStream = MotionObservable<WhichStream> { observer in
      observer.state(.active)
      observer.next(.preferredStream)
      return noopDisconnect
    }

    var observedValues: [WhichStream] = []
    let _ = stream.toggled(with: preferredStream).subscribe(next: {
      observedValues.append($0)
    }, state: { _ in })

    XCTAssertEqual(observedValues, [.preferredStream])
  }

  // stream at rest / preferred stream at rest
  func testEmitsPreferredWhenBothAtRest() {
    let stream = MotionObservable<WhichStream> { observer in
      observer.state(.atRest)
      observer.next(.stream)
      return noopDisconnect
    }

    let preferredStream = MotionObservable<WhichStream> { observer in
      observer.state(.atRest)
      observer.next(.preferredStream)
      return noopDisconnect
    }

    var observedValues: [WhichStream] = []
    let _ = stream.toggled(with: preferredStream).subscribe(next: {
      observedValues.append($0)
    }, state: { _ in })

    XCTAssertEqual(observedValues, [.stream])
  }

  // stream active / preferred stream at rest
  func testEmitsStreamWhenPreferredAtRest() {
    let stream = MotionObservable<WhichStream> { observer in
      observer.state(.active)
      observer.next(.stream)
      return noopDisconnect
    }

    let preferredStream = MotionObservable<WhichStream> { observer in
      observer.state(.atRest)
      observer.next(.preferredStream)
      return noopDisconnect
    }

    var observedValues: [WhichStream] = []
    let _ = stream.toggled(with: preferredStream).subscribe(next: {
      observedValues.append($0)
    }, state: { _ in })

    XCTAssertEqual(observedValues, [.stream])
  }

  // stream at rest / preferred stream active
  func testEmitsPreferredStreamWhenPreferredIsActive() {
    let stream = MotionObservable<WhichStream> { observer in
      observer.state(.atRest)
      observer.next(.stream)
      return noopDisconnect
    }

    let preferredStream = MotionObservable<WhichStream> { observer in
      observer.state(.active)
      observer.next(.preferredStream)
      return noopDisconnect
    }

    var observedValues: [WhichStream] = []
    let _ = stream.toggled(with: preferredStream).subscribe(next: {
      observedValues.append($0)
    }, state: { _ in })

    XCTAssertEqual(observedValues, [.preferredStream])
  }
}
