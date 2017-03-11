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

  /** Writes any incoming value to the console and then passes the value on. */
  public func log(_ context: String? = nil) -> MotionObservable<T> {
    return _nextOperator(#function, args: [context as Any], operation: { value, next in
      if let context = context {
        print(context, value)
      } else {
        print(value)
      }
      next(value)
    }, coreAnimation: { event, coreAnimation in
      coreAnimation?(event)
    })
  }
}

public class LogTracer: Tracer {
  public init() {
    
  }
  public func trace(metadata: Metadata, value: Any) {
    print("\(metadata.name): \(value)")
  }
}

extension MotionObservableConvertible {

  /** Writes any incoming value to the console and then passes the value on. */
  public func trace(with tracer: Tracer) -> MotionObservable<T> {
    return MotionObservable(self.metadata.createChild(Metadata(#function, type: .constraint))) { observer in
      return self.subscribe(next: observer.next,
                            coreAnimation: { event in observer.coreAnimation?(event) },
                            visualization: { view in observer.visualization?(view) },
                            tracer: tracer).unsubscribe
    }
  }
}
