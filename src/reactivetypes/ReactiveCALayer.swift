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

import IndefiniteObservable
import UIKit

public class ReactiveCALayer {
  public let layer: CALayer

  public lazy var cornerRadius: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.cornerRadius,
                                       externalWrite: { layer.cornerRadius = $0 },
                                       keyPath: "cornerRadius",
                                       reactiveLayer: self)
  }()

  public lazy var opacity: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: CGFloat(layer.opacity),
                                       externalWrite: { layer.opacity = Float($0) },
                                       keyPath: "opacity",
                                       reactiveLayer: self)
  }()

  public lazy var position: ReactiveProperty<CGPoint> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.position,
                                       externalWrite: { layer.position = $0 },
                                       keyPath: "position",
                                       reactiveLayer: self)
  }()

  public lazy var positionX: ReactiveProperty<CGFloat> = {
    let position = self.position
    return createCoreAnimationProperty(#function,
                                       initialValue: position.value.x,
                                       externalWrite: { var point = position.value; point.x = $0; position.value = point },
                                       keyPath: "position.x",
                                       reactiveLayer: self)
  }()

  public lazy var positionY: ReactiveProperty<CGFloat> = {
    let position = self.position
    return createCoreAnimationProperty(#function,
                                       initialValue: position.value.y,
                                       externalWrite: { var point = position.value; point.y = $0; position.value = point },
                                       keyPath: "position.y",
                                       reactiveLayer: self)
  }()

  public lazy var size: ReactiveProperty<CGSize> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.bounds.size,
                                       externalWrite: { layer.bounds.size = $0 },
                                       keyPath: "bounds.size",
                                       reactiveLayer: self)
  }()

  public lazy var width: ReactiveProperty<CGFloat> = {
    let size = self.size
    return createCoreAnimationProperty(#function,
                                       initialValue: size.value.width,
                                       externalWrite: { var dimensions = size.value; dimensions.width = $0; size.value = dimensions },
                                       keyPath: "bounds.size.width",
                                       reactiveLayer: self)
  }()

  public lazy var height: ReactiveProperty<CGFloat> = {
    let size = self.size
    return createCoreAnimationProperty(#function,
                                       initialValue: size.value.height,
                                       externalWrite: { var dimensions = size.value; dimensions.height = $0; size.value = dimensions },
                                       keyPath: "bounds.size.height",
                                       reactiveLayer: self)
  }()

  public lazy var anchorPoint: ReactiveProperty<CGPoint> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.anchorPoint,
                                       externalWrite: { layer.anchorPoint = $0 },
                                       keyPath: "anchorPoint",
                                       reactiveLayer: self)
  }()

  public lazy var anchorPointAdjustment: ReactiveProperty<AnchorPointAdjustment> = {
    let anchorPoint = self.anchorPoint
    let position = self.position
    let layer = self.layer
    return ReactiveProperty(#function,
                            initialValue: .init(anchorPoint: anchorPoint.value, position: position.value),
                            externalWrite: { anchorPoint.value = $0.anchorPoint; position.value = $0.position })
  }()

  public lazy var rotation: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.value(forKeyPath: "transform.rotation.z") as! CGFloat,
                                       externalWrite: { layer.setValue($0, forKeyPath: "transform.rotation.z") },
                                       keyPath: "transform.rotation.z",
                                       reactiveLayer: self)
  }()

  public lazy var scale: ReactiveProperty<CGFloat> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.value(forKeyPath: "transform.scale") as! CGFloat,
                                       externalWrite: { layer.setValue($0, forKeyPath: "transform.scale") },
                                       keyPath: "transform.scale.xy",
                                       reactiveLayer: self)
  }()

  public lazy var shadowPath: ReactiveProperty<CGPath> = {
    let layer = self.layer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.shadowPath!,
                                       externalWrite: { layer.shadowPath = $0 },
                                       keyPath: "shadowPath",
                                       reactiveLayer: self)
  }()

  fileprivate var timeline: Timeline? {
    didSet {
      if oldValue === timeline {
        return
      }
      guard let timeline = timeline else {
        timelineSubscription = nil
        return
      }

      timelineSubscription = timeline.subscribeToValue { [weak self] state in
        guard let strongSelf = self else { return }
        strongSelf.lastTimelineState = state

        if state.paused {
          strongSelf.layer.speed = 0
          strongSelf.layer.timeOffset = TimeInterval(state.beginTime + state.timeOffset)

        } else if strongSelf.layer.speed == 0 { // Unpause the layer.
          // The following logic is the magic sauce required to reconnect a CALayer with the
          // render server's clock.
          let pausedTime = strongSelf.layer.timeOffset
          strongSelf.layer.speed = 1
          strongSelf.layer.timeOffset = 0
          strongSelf.layer.beginTime = 0
          let timeSincePause = strongSelf.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
          strongSelf.layer.beginTime = timeSincePause
        }
      }
    }
  }
  fileprivate var decomposedKeys = Set<String>()
  fileprivate var lastTimelineState: Timeline.Snapshot?
  private var timelineSubscription: Subscription?

  init(_ layer: CALayer) {
    self.layer = layer
  }
}

/**
 Creates a Core Animation-compatible reactive property instance.
 */
public func createCoreAnimationProperty<T>(_ name: String, initialValue: T, externalWrite: @escaping NextChannel<T>, keyPath: String, reactiveLayer: ReactiveCALayer) -> ReactiveProperty<T> {
  let layer = reactiveLayer.layer
  let property = ReactiveProperty("\(pretty(reactiveLayer)).\(name)", initialValue: initialValue, externalWrite: { value in
    let actionsWereDisabled = CATransaction.disableActions()
    CATransaction.setDisableActions(true)
    externalWrite(value)
    CATransaction.setDisableActions(actionsWereDisabled)
  }, coreAnimation: { [weak reactiveLayer] event in
    guard let strongReactiveLayer = reactiveLayer else { return }
    switch event {
    case .add(let info):
      if let timeline = info.timeline {
        strongReactiveLayer.timeline = timeline
      }

      let animation = info.animation.copy() as! CAPropertyAnimation

      animation.duration *= TimeInterval(simulatorDragCoefficient())

      if layer.speed == 0, let lastTimelineState = strongReactiveLayer.lastTimelineState {
        animation.beginTime = TimeInterval(lastTimelineState.beginTime) + animation.beginTime
      } else {
        animation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + animation.beginTime
      }

      animation.keyPath = keyPath

      if let unsafeMakeAdditive = info.makeAdditive {
        let makeAdditive: ((Any, Any) -> Any) = { from, to in
          // When mapping properties to properties it's possible for the values to get implicitly
          // wrapped in an NSNumber instance. This may cause the generic makeAdditive
          // implementation to fail to cast to T, so we unbox the type here instead.
          if let from = from as? NSNumber, let to = to as? NSNumber {
            return from.doubleValue - to.doubleValue
          }
          return unsafeMakeAdditive(from, to)
        }

        if let basicAnimation = animation as? CABasicAnimation {
          basicAnimation.fromValue = makeAdditive(basicAnimation.fromValue!, basicAnimation.toValue!)
          basicAnimation.toValue = makeAdditive(basicAnimation.toValue!, basicAnimation.toValue!)
          basicAnimation.isAdditive = true

        } else if let keyframeAnimation = animation as? CAKeyframeAnimation {
          let lastValue = keyframeAnimation.values!.last!
          keyframeAnimation.values = keyframeAnimation.values!.map { makeAdditive($0, lastValue) }
          keyframeAnimation.isAdditive = true
        }
      }

      // Core Animation springs do not support multi-dimensional velocity, so we bear the burden
      // of decomposing multi-dimensional springs here.
      if let springAnimation = animation as? CASpringAnimation
        , springAnimation.isAdditive
        , let initialVelocity = info.initialVelocity as? CGPoint
        , let delta = springAnimation.fromValue as? CGPoint {
        let decomposed = decompose(springAnimation: springAnimation,
                                   delta: delta,
                                   initialVelocity: initialVelocity)

        CATransaction.begin()
        CATransaction.setCompletionBlock(info.onCompletion)
        layer.add(decomposed.0, forKey: info.key + ".x")
        layer.add(decomposed.1, forKey: info.key + ".y")
        CATransaction.commit()

        strongReactiveLayer.decomposedKeys.insert(info.key)
        return
      }

      if let initialVelocity = info.initialVelocity {
        applyInitialVelocity(initialVelocity, to: animation)
      }

      CATransaction.begin()
      CATransaction.setCompletionBlock(info.onCompletion)
      layer.add(animation, forKey: info.key + "." + keyPath)
      CATransaction.commit()

    case .remove(let key):
      if let presentationLayer = layer.presentation() {
        layer.setValue(presentationLayer.value(forKeyPath: keyPath), forKeyPath: keyPath)
      }
      if strongReactiveLayer.decomposedKeys.contains(key) {
        layer.removeAnimation(forKey: key + ".x")
        layer.removeAnimation(forKey: key + ".y")
        strongReactiveLayer.decomposedKeys.remove(key)

      } else {
        layer.removeAnimation(forKey: key + "." + keyPath)
      }
    }
  })
  var lastView: UIView?
  property.shouldVisualizeMotion = { view, containerView in
    if lastView != view, let lastView = lastView {
      lastView.removeFromSuperview()
    }
    view.isUserInteractionEnabled = false
    view.frame = layer.superlayer!.convert(layer.superlayer!.bounds, to: containerView.layer)
    containerView.addSubview(view)
    lastView = view
  }

  return property
}

public class ReactiveCAShapeLayer: ReactiveCALayer {
  public let shapeLayer: CAShapeLayer

  /** A property representing the layer's .path value. */
  public lazy var path: ReactiveProperty<CGPath> = {
    let layer = self.shapeLayer
    return createCoreAnimationProperty(#function,
                                       initialValue: layer.path!,
                                       externalWrite: { layer.path = $0 },
                                       keyPath: "path",
                                       reactiveLayer: self)
  }()

  init(_ shapeLayer: CAShapeLayer) {
    self.shapeLayer = shapeLayer
    super.init(shapeLayer)
  }
}

private func decompose(springAnimation: CASpringAnimation, delta: CGPoint, initialVelocity: CGPoint) -> (CASpringAnimation, CASpringAnimation) {
  let xAnimation = springAnimation.copy() as! CASpringAnimation
  let yAnimation = springAnimation.copy() as! CASpringAnimation
  xAnimation.fromValue = delta.x
  yAnimation.fromValue = delta.y
  xAnimation.toValue = 0
  yAnimation.toValue = 0

  if delta.x != 0 {
    xAnimation.initialVelocity = initialVelocity.x / -delta.x
  }
  if delta.y != 0 {
    yAnimation.initialVelocity = initialVelocity.y / -delta.y
  }

  xAnimation.keyPath = springAnimation.keyPath! + ".x"
  yAnimation.keyPath = springAnimation.keyPath! + ".y"

  return (xAnimation, yAnimation)
}

private func applyInitialVelocity(_ initialVelocity: Any, to animation: CAPropertyAnimation) {
  if let springAnimation = animation as? CASpringAnimation, springAnimation.isAdditive {
    // Additive animations have a toValue of 0 and a fromValue of negative delta (where the model
    // value came from).
    guard let initialVelocity = initialVelocity as? CGFloat, let delta = springAnimation.fromValue as? CGFloat else {
      // Unsupported velocity type.
      return
    }
    if delta != 0 {
      // CASpringAnimation's initialVelocity is proportional to the distance to travel, i.e. our
      // delta.
      springAnimation.initialVelocity = initialVelocity / -delta
    }
  }
}
