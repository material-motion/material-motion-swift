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

  init(_ position: CGPoint) {
    property = createProperty(withInitialValue: position)
  }

  public let property: ReactiveProperty<CGPoint>

  public func asStream() -> MotionObservable<CGPoint> {
    return property.stream
  }
}

public class Tossable: ViewInteraction {

  public let draggable = Draggable()
  public let spring: Spring<CGPoint>

  init(destination: Destination, system: @escaping SpringToStream<CGPoint>) {
    self.destination = destination
    self.spring = Spring(threshold: 1, system: system)
  }

  public func add(to reactiveView: ReactiveUIView, withRuntime runtime: MotionRuntime) {
    let position = reactiveView.reactiveLayer.position
    let relativeView = draggable.relativeView ?? runtime.containerView
    let gesture = runtime.get(draggable.gestureRecognizer)

    runtime.add(gesture.translated(from: position, in: relativeView), to: position)

    runtime.add(destination.asStream(), to: spring.destination)
    runtime.add(position.asStream(), to: spring.initialValue)
    runtime.add(gesture.velocityOnReleaseStream(in: relativeView), to: spring.initialVelocity)
    runtime.add(spring, to: position)

    runtime.add(gesture.atRest(), to: spring.enabled)
  }

  fileprivate let destination: Destination
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
