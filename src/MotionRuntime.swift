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
import UIKit
import IndefiniteObservable

/**
 A motion runtime provides a mechanism for associating interactions with targets.

 Runtimes are cheap to create and scoped a specific view hierarchy. You typically create a new
 runtime for each view controller that plans to make use of reactive motion.

 The simplest primitive of a motion runtime is a connection from a stream to a reactive property.
 Interactions are expected to create these connections when added to the runtime.

 Runtimes also act as a cache for reactive objects, ensuring that any associated reactive property
 instances are consistently used.
 */
public final class MotionRuntime {

  /**
   Creates a motion runtime instance with the provided container view.
   */
  public init(containerView: UIView) {
    self.containerView = containerView
  }

  /**
   In general, the container view is the view within which all motion associated to this runtime
   occurs.

   Interactions make use of the container view when doing things like registering gesture
   recognizers and calculating relative coordinates.
   */
  public let containerView: UIView

  /**
   When enabled, debug visualizations will be drawn atop the container view for any interactions
   that support debug visualization.
   */
  public var shouldVisualizeMotion = false

  /**
   Associates an interaction with the runtime.

   Invokes the interaction's add method and stores the interaction instance for the lifetime of the
   runtime.
   */
  public func add<I: Interaction>(_ interaction: I, to target: I.Target, constraints: I.Constraints? = nil) {
    interactions.append(interaction)
    interaction.add(to: target, withRuntime: self, constraints: constraints)
  }

  /**
   Creates a toggling association between one interaction's state and the other interaction's
   enabling.

   The provided interaction will be disabled when otherInteraction's state is active, and enabled
   when otherInteraction's state is at rest.

   This is most commonly used to disable a spring when a gestural interaction is active.
   */
  public func toggle(_ interaction: Togglable, inReactionTo otherInteraction: Stateful) {
    connect(otherInteraction.state.rewrite([.atRest: true, .active: false]), to: interaction.enabled)
  }

  /**
   Initiates an interaction by disabling and then immediately re-enabling the interaction when the
   otherInteraction's state is active.
   */
  public func start(_ interaction: Togglable, whenActive otherInteraction: Stateful) {
    let state = otherInteraction.state.dedupe()
    interaction.enabled.value = false
    connect(state.rewrite([.active: false]), to: interaction.enabled)
    connect(state.rewrite([.active: true]), to: interaction.enabled)
  }

  /**
   Connects a stream's output to a reactive property.

   This method is primarily intended to be used by interactions and its presence in application
   logic implies that an applicable interaction is not available.
   */
  public func connect<O: MotionObservableConvertible>(_ stream: O, to property: ReactiveProperty<O.T>) {
    write(stream.asStream(), to: property)
  }

  // MARK: Reactive object storage

  /**
   Returns a reactive version of the given object and caches the returned result for future access.
   */
  public func get(_ view: UIView) -> ReactiveUIView {
    return get(view) { .init($0, runtime: self) }
  }

  /**
   Returns a reactive version of the given object and caches the returned result for future access.
   */
  public func get(_ layer: CALayer) -> ReactiveCALayer {
    return get(layer) { .init($0) }
  }

  /**
   Returns a reactive version of the given object and caches the returned result for future access.
   */
  public func get(_ layer: CAShapeLayer) -> ReactiveCAShapeLayer {
    return get(layer) { .init($0) }
  }

  /**
   Returns a reactive version of the given object and caches the returned result for future access.
   */
  public func get(_ scrollView: UIScrollView) -> MotionObservable<CGPoint> {
    return get(scrollView) { scrollViewToStream($0) }
  }

  /**
   Returns a reactive version of the given object and caches the returned result for future access.
   */
  public func get<O: UIGestureRecognizer>(_ gestureRecognizer: O) -> ReactiveUIGestureRecognizer<O> {
    return get(gestureRecognizer) {
      let reactiveObject = ReactiveUIGestureRecognizer<O>($0, containerView: containerView)

      if reactiveObject.gestureRecognizer.view == nil {
        containerView.addGestureRecognizer(reactiveObject.gestureRecognizer)
      }
      return reactiveObject
    }
  }

  /**
   Executes a block when all of the provided Stateful interactions have come to rest.
   */
  public func whenAllAtRest(_ interactions: [Stateful], body: @escaping () -> Void) {
    guard interactions.count > 0 else {
      body()
      return
    }
    var subscriptions: [Subscription] = []
    var activeIndices = Set<Int>()
    for (index, stream) in interactions.enumerated() {
      subscriptions.append(stream.state.dedupe().subscribeToValue { state in
        if state == .active {
          activeIndices.insert(index)

        } else if activeIndices.contains(index) {
          activeIndices.remove(index)

          if activeIndices.count == 0 {
            body()
          }
        }
      })
    }
    self.subscriptions.append(contentsOf: subscriptions)
  }

  /**
   Generates a graphviz-compatiable representation of all interactions associated with the runtime.

   For quick previewing, use an online graphviz visualization tool like http://www.webgraphviz.com/
   */
  public func asGraphviz() -> String {
    var lines: [String] = [
      "digraph G {",
      "node [shape=rect]"
    ]
    for metadata in metadata {
      lines.append(metadata.debugDescription)
    }
    lines.append("}")
    return lines.joined(separator: "\n")
  }

  private func write<O: MotionObservableConvertible, T>(_ stream: O, to property: ReactiveProperty<T>) where O.T == T {
    metadata.append(stream.metadata.createChild(property.metadata))
    subscriptions.append(stream.subscribe(next: { property.value = $0 },
                                          coreAnimation: property.coreAnimation,
                                          visualization: { [weak self] view in
                                            guard let strongSelf = self else { return }
                                            if !strongSelf.shouldVisualizeMotion { return }
                                            property.visualize(view, in: strongSelf.containerView)
    }))
  }

  private func get<T: AnyObject, U: AnyObject>(_ object: T, initializer: (T) -> U) -> U {
    let identifier = ObjectIdentifier(object)
    if let reactiveObject = reactiveObjects[identifier] {
      // If a UIPanGestureRecognizer is fetched using runtime.get while typed as a
      // UIGestureRecognizer, the ReactiveUIGestureRecognizer instance will be created as a
      // ReactiveUIGestureRecognizer<UIGestureRecognizer>, meaning we can't cast using as down to a
      // ReactiveUIGestureRecognizer<UIPanGestureRecognizer>. We know this is safe to do within the
      // context of the runtime, so we do a forced bit cast here instead of an `as` cast.
      return unsafeBitCast(reactiveObject, to: U.self)
    }
    let reactiveObject = initializer(object)
    reactiveObjects[identifier] = reactiveObject
    return reactiveObject
  }
  private var reactiveObjects: [ObjectIdentifier: AnyObject] = [:]

  private var metadata: [Metadata] = []
  private var subscriptions: [Subscription] = []
  private var interactions: [Any] = []
}
