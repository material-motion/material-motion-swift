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
import UIKit

/** A timeline makes it possible to pause and scrub animations. */
public class Timeline {
  public var paused = createProperty(withInitialValue: false)
  public let timeOffset = createProperty(withInitialValue: TimeInterval(0))

  public init() {
    subscriptions.append(paused.asStream().dedupe().subscribe(next: { [weak self] offset in
      guard let strongSelf = self else { return }
      for layer in strongSelf.layers {
        strongSelf.updateTiming(for: layer)
      }
    }, state: { _ in }, coreAnimation: { _ in }))

    subscriptions.append(timeOffset.asStream().dedupe().subscribe(next: { [weak self] offset in
      guard let strongSelf = self else { return }
      guard strongSelf.paused.value else { return }
      for layer in strongSelf.layers {
        strongSelf.updateTimeOffset(for: layer, timeOffset: offset)
      }
    }, state: { _ in }, coreAnimation: { _ in }))
  }
  private var subscriptions: [Subscription] = []

  let beginTime = CACurrentMediaTime()

  func addLayer(_ layer: CALayer) {
    if layers.contains(layer) { return } // No need to reconfigure

    layers.insert(layer)
    updateTiming(for: layer)
  }
  private var layers = Set<CALayer>()

  func animationBeginTime(for layer: CALayer) -> TimeInterval {
    let beginTime: TimeInterval
    if layer.speed == 0 {
      beginTime = self.beginTime
    } else {
      beginTime = layer.convertTime(CACurrentMediaTime(), from: nil)
    }
    return beginTime
  }

  private func updateTiming(for layer: CALayer) {
    if paused.value {
      pause(layer)
    } else {
      unpause(layer)
    }
  }

  private func pause(_ layer: CALayer) {
    layer.speed = 0
    layer.timeOffset = beginTime + timeOffset.value
  }

  private func unpause(_ layer: CALayer) {
    let pausedTime = layer.timeOffset
    layer.speed = 1
    layer.timeOffset = 0
    layer.beginTime = 0
    let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    layer.beginTime = timeSincePause
  }

  private func updateTimeOffset(for layer: CALayer, timeOffset: TimeInterval) {
    layer.timeOffset = beginTime + timeOffset
  }
}
