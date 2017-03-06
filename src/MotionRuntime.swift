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
 A MotionRuntime manages the connections from streams to reactive properties.
 */
public final class MotionRuntime {

  /** All motion in this runtime is relative to this view. */
  public let containerView: UIView

  /** Whether this runtime renders debug visualizations. */
  public var visualizer = false

  /** Creates a motion runtime instance. */
  public init(containerView: UIView) {
    self.containerView = containerView
  }

  public func enable(_ interaction: TogglableInteraction, whenAtRest otherInteraction: StatefulInteraction) {
    add(otherInteraction.state.rewrite([.atRest: true, .active: false]), to: interaction.enabled)
  }

  public func add(_ interaction: ViewInteraction, to reactiveView: ReactiveUIView) {
    interaction.add(to: reactiveView, withRuntime: self)
    viewInteractions.append(interaction)
  }

  public func add(_ interaction: ViewInteraction, to view: UIView) {
    add(interaction, to: get(view))
  }

  public func add(_ interaction: CoordinatingInteraction) {
    interaction.add(withRuntime: self)
  }

  public func add<T, P: ReactivePropertyConvertible>(_ stream: MotionObservable<T>, to property: P) where P.T == T {
    write(stream, to: property.asProperty())
  }

  public func add<T, P: ReactivePropertyConvertible>(_ fromProperty: ReactiveProperty<T>, to property: P) where P.T == T {
    write(fromProperty.asStream(), to: property.asProperty())
  }

  public func add<I: PropertyInteraction, P: ReactivePropertyConvertible>(_ interaction: I, to property: P) where I.T == P.T {
    interaction.add(to: property.asProperty(), withRuntime: self)
  }

  public func add<I: TransitionInteraction, P: ReactivePropertyConvertible>(_ interaction: I, to property: P) where I.ValueType == P.T, I: PropertyInteraction {
    let property = property.asProperty()
    property.value = interaction.initialValue()
    interaction.add(to: property as! ReactiveProperty<I.T>, withRuntime: self)
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

  public func get(_ shapeLayer: CAShapeLayer) -> ReactiveCAShapeLayer {
    if let reactiveObject = reactiveShapeLayers[shapeLayer] {
      return reactiveObject
    }
    let reactiveObject = ReactiveCAShapeLayer(shapeLayer)
    reactiveShapeLayers[shapeLayer] = reactiveObject
    return reactiveObject
  }
  private var reactiveShapeLayers: [CAShapeLayer: ReactiveCAShapeLayer] = [:]

  public func get<O: UIGestureRecognizer>(_ gestureRecognizer: O) -> ReactiveUIGestureRecognizer<O> {
    if let reactiveObject = reactiveGestureRecognizers[gestureRecognizer] {
      return unsafeBitCast(reactiveObject, to: ReactiveUIGestureRecognizer<O>.self)
    }

    let reactiveObject = ReactiveUIGestureRecognizer<O>(gestureRecognizer, containerView: containerView)

    if reactiveObject.gestureRecognizer.view == nil {
      containerView.addGestureRecognizer(reactiveObject.gestureRecognizer)
    }

    reactiveGestureRecognizers[gestureRecognizer] = reactiveObject
    return reactiveObject
  }
  private var reactiveGestureRecognizers: [UIGestureRecognizer: AnyObject] = [:]

  public func get(_ scrollView: UIScrollView) -> MotionObservable<CGPoint> {
    if let reactiveObject = reactiveScrollViews[scrollView] {
      return reactiveObject
    }

    let reactiveObject = scrollViewToStream(scrollView)
    reactiveScrollViews[scrollView] = reactiveObject
    return reactiveObject
  }
  private var reactiveScrollViews: [UIScrollView: MotionObservable<CGPoint>] = [:]

  public func whenAllAtRest(_ streams: [StatefulInteraction], body: @escaping () -> Void) {
    guard streams.count > 0 else {
      body()
      return
    }
    var subscriptions: [Subscription] = []
    var activeIndices = Set<Int>()
    for (index, stream) in streams.enumerated() {
      subscriptions.append(stream.state.dedupe().subscribe { state in
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

  private func write<O: MotionObservableConvertible, T>(_ stream: O, to property: ReactiveProperty<T>) where O.T == T {
    //
    // let metadata = stream.metadata.createChild(property.metadata)
    // print(metadata)
    //
    // ^ dumps the connected stream to the console so that it can be visualized in graphviz.
    //
    // Place the output in the following graphviz structure:
    // digraph G {
    //   node [shape=rect]
    //   <place output here>
    // }
    //
    // For quick previewing, use an online graphviz visualizer like http://www.webgraphviz.com/

    subscriptions.append(stream.subscribe(next: { property.value = $0 },
                                          coreAnimation: property.coreAnimation,
                                          visualization: { [weak self] view in
                                            guard let strongSelf = self else { return }
                                            if !strongSelf.visualizer { return }
                                            property.visualize(view, in: strongSelf.containerView)
    }))
  }

  private var subscriptions: [Subscription] = []
  private var viewInteractions: [ViewInteraction] = []
}
