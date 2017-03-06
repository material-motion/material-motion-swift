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

public class Destination: MotionObservableConvertible {
  init(_ view: ReactiveUIView) {
    property = view.center
  }

  init(_ position: CGPoint = .zero()) {
    property = createProperty("Destination.position", withInitialValue: position)
  }

  public let property: ReactiveProperty<CGPoint>

  public let metadata = Metadata("Destination")

  public func asStream() -> MotionObservable<CGPoint> {
    return property.asStream()
  }
}

public class Tossable {

  public let draggable: Draggable
  public let spring: Spring<CGPoint>

  init(destination: Destination, system: @escaping SpringToStream<CGPoint>, draggable: Draggable = Draggable()) {
    self.destination = destination
    self.spring = Spring(threshold: 1, system: system)
    self.draggable = draggable
  }

  fileprivate let destination: Destination
}

extension Tossable: ViewInteraction {
  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    let position = reactiveView.reactiveLayer.position

    let gesture = runtime.get(draggable.nextGestureRecognizer)

    runtime.add(draggable, to: reactiveView)
    runtime.add(destination.asStream(), to: spring.destination)
    runtime.add(gesture.velocityOnReleaseStream(in: runtime.containerView), to: spring.initialVelocity)
    runtime.add(spring, to: position)

    runtime.add(gesture.atRest(), to: spring.enabled)
  }
}

extension Destination: ReactivePropertyConvertible {
  public func asProperty() -> ReactiveProperty<CGPoint> {
    return property
  }
}

extension Tossable: ReactivePropertyConvertible {
  public func asProperty() -> ReactiveProperty<CGPoint> {
    return destination.property
  }
}
