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
import IndefiniteObservable

/**
 A MotionRuntime writes the output of streams to properties and observes their overall state.
 */
public class MotionRuntime {

  /** All motion in this runtime is relative to this view. */
  public let containerView: UIView

  /**
   The aggregate state of all registered streams.

   If any stream is active, the aggregate state is active. Otherwise, the aggregate state is at
   rest.
   */
  public let state = createProperty(withInitialValue: MotionState.atRest)

  /** Creates a motion runtime instance. */
  public init(containerView: UIView) {
    self.parent = nil
    self.containerView = containerView
  }

  /** Connects the interaction's streams and stores the interaction. */
  public func addInteraction(_ interaction: Interaction) {
    interaction.connect(with: self)
    interactions.append(interaction)
  }

  public func get(_ view: UIView) -> ReactiveUIView {
    if let reactiveObject = reactiveViews[view] {
      return reactiveObject
    }
    let reactiveObject = ReactiveUIView(view, runtime: self)
    reactiveViews[view] = reactiveObject
    return reactiveObject
  }
  private var reactiveViews: [UIView: ReactiveUIView] = [:]

  public func get(_ layer: CALayer) -> ReactiveCALayer {
    if let reactiveObject = reactiveLayers[layer] {
      return reactiveObject
    }
    let reactiveObject = ReactiveCALayer(layer)
    reactiveLayers[layer] = reactiveObject
    return reactiveObject
  }
  private var reactiveLayers: [CALayer: ReactiveCALayer] = [:]

  public func get<O: UIGestureRecognizer>(_ gestureRecognizer: O) -> ReactiveUIGestureRecognizer<O> {
    if let reactiveObject = reactiveGestureRecognizers[gestureRecognizer] {
      return unsafeBitCast(reactiveObject, to: ReactiveUIGestureRecognizer<O>.self)
    }

    let reactiveObject = ReactiveUIGestureRecognizer<O>(gestureRecognizer)

    if reactiveObject.gestureRecognizer.view == nil {
      containerView.addGestureRecognizer(reactiveObject.gestureRecognizer)
    }

    reactiveGestureRecognizers[gestureRecognizer] = reactiveObject as! ReactiveUIGestureRecognizer<O>
    return reactiveObject
  }
  private var reactiveGestureRecognizers: [UIGestureRecognizer: AnyObject] = [:]

  /** Subscribes to the stream, writes its output to the given property, and observes its state. */
  public func write<O: MotionObservableConvertible, T>(_ stream: O, to property: ReactiveProperty<T>) where O.T == T {
    let token = NSUUID().uuidString
    subscriptions.append(stream.asStream().subscribe(next: property.setValue, state: { [weak self] state in
      property.state(state)

      guard let strongSelf = self else { return }
      strongSelf.stateDidChange(state, for: token)

    }, coreAnimation: property.coreAnimation))
  }

  /**
   Creates a child runtime instance.

   Streams registered to a child runtime will affect the state on that runtime and all of its
   ancestors.
   */
  public func createChild() -> MotionRuntime {
    return MotionRuntime(parent: self)
  }

  /** Creates a child motion runtime instance. */
  private init(parent: MotionRuntime) {
    self.parent = parent
    self.containerView = parent.containerView
    parent.children.append(self)
  }

  private func stateDidChange(_ state: MotionState, for token: String) {
    if state == .active {
      activeSubscriptions.insert(token)
    } else {
      activeSubscriptions.remove(token)
    }

    let oldState = self.state.value
    let newState: MotionState = activeSubscriptions.count > 0 ? .active : .atRest
    if oldState != newState {
      self.state.setValue(newState)
    }

    if let parent = parent {
      parent.stateDidChange(state, for: token)
    }
  }

  private weak var parent: MotionRuntime?
  private var children: [MotionRuntime] = []
  private var subscriptions: [Subscription] = []
  private var interactions: [Interaction] = []

  private typealias Token = String
  private var activeSubscriptions = Set<Token>()
}
