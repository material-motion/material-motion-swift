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

extension MotionObservableConvertible {

  /**
   A light-weight operator builder.

   This is the preferred method for building new operators. This builder can be used to create any
   operator that only needs to modify values. All state events are forwarded along.
   */
  func _nextOperator<U>(_ name: String? = nil, args: [Any]? = nil, operation: @escaping (T, @escaping (U) -> Void) -> Void) -> MotionObservable<U> {
    return MotionObservable<U>(self.metadata.createChild(Metadata(name, args: args), type: .constraint)) { observer in
      return self.subscribe(next: {
        return operation($0, observer.next)
      }, coreAnimation: { _ in
        assertionFailure("Core animation is not supported by this operator.")
      }, visualization: { view in observer.visualization?(view) }).unsubscribe
    }
  }

  /**
   A light-weight operator builder with core animation support.

   This is the preferred method for building new operators that support core animation. This builder
   can be used to create any operator that only needs to modify values. All state events are
   forwarded along.
   */
  func _nextOperator<U>(_ name: String? = nil, args: [Any]? = nil, operation: @escaping (T, (U) -> Void) -> Void, coreAnimation: @escaping (CoreAnimationChannelEvent, CoreAnimationChannel?) -> Void) -> MotionObservable<U> {
    return MotionObservable<U>(self.metadata.createChild(Metadata(name, args: args), type: .constraint)) { observer in
      return self.subscribe(next: {
        return operation($0, observer.next)
      }, coreAnimation: {
        return coreAnimation($0, observer.coreAnimation)
      }, visualization: { view in observer.visualization?(view) }).unsubscribe
    }
  }
}
