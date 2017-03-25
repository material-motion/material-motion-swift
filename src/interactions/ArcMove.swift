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

/**
 Calculates an arc path between two points and uses a PathTween interaction to move between the two
 points.

 **Affected properties**

 - `view.layer.position`
 */
public final class ArcMove: Interaction, Togglable, Stateful {

  /**
   The initial position of the arc move animation.
   */
  public let from = createProperty("ArcMove.from", withInitialValue: CGPoint.zero)

  /**
   The final position of the arc move animation.
   */
  public let to = createProperty("ArcMove.to", withInitialValue: CGPoint.zero)

  /**
   The tween interaction that will interpolate between the from and to values.
   */
  public let tween: PathTween

  /**
   Initializes an arc move instance with its required properties.
   */
  public init(tween: PathTween = PathTween()) {
    self.tween = tween
  }

  public func add(to view: UIView, withRuntime runtime: MotionRuntime, constraints: NoConstraints) {
    runtime.connect(arcMove(from: from, to: to), to: tween.path)
    runtime.add(tween, to: runtime.get(view.layer).position)
  }

  public var enabled: ReactiveProperty<Bool> {
    return tween.enabled
  }

  public var state: MotionObservable<MotionState> {
    return tween.state
  }

  public let metadata = Metadata("ArcMove")
}

// Given two positional streams, returns a stream that emits an arc move path between the two
// positions.
private func arcMove<O1: MotionObservableConvertible, O2: MotionObservableConvertible>
  (from: O1, to: O2)
  -> MotionObservable<CGPath> where O1.T == CGPoint, O2.T == CGPoint {
    return MotionObservable(Metadata(#function, args: [from, to])) { observer in
      var latestFrom: CGPoint?
      var latestTo: CGPoint?

      let checkAndEmit = {
        guard let from = latestFrom, let to = latestTo else {
          return
        }
        let path = UIBezierPath()

        path.move(to: from)

        let controlPoints = arcMovement(from: from, to: to)
        path.addCurve(to: to, controlPoint1: controlPoints.point1, controlPoint2: controlPoints.point2)

        observer.next(path.cgPath)
      }

      let fromSubscription = from.subscribeToValue { fromValue in
        latestFrom = fromValue
        checkAndEmit()
      }

      let toSubscription = to.subscribeToValue { toValue in
        latestTo = toValue
        checkAndEmit()
      }

      return {
        fromSubscription.unsubscribe()
        toSubscription.unsubscribe()
      }
    }
}

private let defaultMinArcAngle: CGFloat = 10.0
private let defaultMaxArcAngle: CGFloat = 90.0

private func rad2deg(_ radians: CGFloat) -> CGFloat {
  return radians * 180.0 / CGFloat(Double.pi)
}

private func deg2rad(_ degrees: CGFloat) -> CGFloat {
  return degrees * CGFloat(Double.pi) / 180.0
}

private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
  let deltaX = to.x - from.x
  let deltaY = to.y - from.y
  return sqrt(deltaX * deltaX + deltaY * deltaY)
}

private func normalized(_ point: CGPoint) -> CGPoint {
  let length = sqrt(point.x * point.x + point.y * point.y)
  if length < CGFloat(Double.ulpOfOne) {
    return .zero
  }
  return CGPoint(x: point.x / length, y: point.y / length)
}

private struct ControlPoints {
  let point1: CGPoint
  let point2: CGPoint
}

// Returns control points for usage when calculating a cubic bezier path that matches
// material motion spec. This typically results in a curve that is part of a circle.
//
// The naming of variables in this method follows the diagram available here:
// https://github.com/material-motion/material-motion/blob/gh-pages/assets/arcmove.png
private func arcMovement(from: CGPoint, to: CGPoint) -> ControlPoints {
  if from == to {
    return ControlPoints(point1: from, point2: to)
  }

  let minArcAngleRad = deg2rad(defaultMinArcAngle)

  let deltaX = to.x - from.x
  let deltaY = to.y - from.y

  let pointC = CGPoint(x: to.x, y: from.y)
  let pointD = CGPoint(x: (from.x + to.x) * 0.5, y: (from.y + to.y) * 0.5)

  // Calculate side lengths
  let lenAB = distance(from: from, to: to)
  let lenAC = distance(from: from, to: pointC)
  let lenBC = distance(from: to, to: pointC)

  // Length AD is half length AB
  let lenAD = lenAB * 0.5

  // Angle alpha
  let alpha: CGFloat
  if abs(deltaX) > abs(deltaY) {
    alpha = cos(lenAC / lenAB)
  } else {
    alpha = cos(lenBC / lenAB)
  }

  // Alpha in degrees
  let alphaDeg = rad2deg(alpha)

  // Calculate point E
  let lenAE = lenAD / cos(alpha)
  let pointE: CGPoint
  if from.y == to.y {
    pointE = pointD
  } else if abs(deltaX) > abs(deltaY) {
    let normalizedCFrom = normalized(CGPoint(x: pointC.x - from.x, y: pointC.y - from.y))
    pointE = CGPoint(x: from.x + (normalizedCFrom.x * lenAE),
                     y: from.y + (normalizedCFrom.y * lenAE))
  } else {
    let normalizedCTo = normalized(CGPoint(x: pointC.x - to.x, y: pointC.y - to.y))
    pointE = CGPoint(x: to.x + (normalizedCTo.x * lenAE),
                     y: to.y + (normalizedCTo.y * lenAE))
  }

  // Constrain DE to account for min/max arc segment

  let arcAngleClampDeg = min(defaultMaxArcAngle, max(defaultMinArcAngle, alphaDeg * 2.0))

  let arcAngleClamp = deg2rad(arcAngleClampDeg)
  let alphaClamp = arcAngleClamp / 2.0
  let maxLen = lenAD * tan(alphaClamp)

  // Point E'
  let pointE2: CGPoint
  let vDE = CGPoint(x: pointE.x - pointD.x, y: pointE.y - pointD.y)
  let lenDE = distance(from: .zero, to: vDE)

  var adjMinLen: CGFloat
  if defaultMinArcAngle > 0 {
    let tanMinArcAngleRad = tan(minArcAngleRad)
    if abs(tanMinArcAngleRad) < CGFloat(Double.ulpOfOne) {
      // Protection against possible divide by zero - shouldn't happen in practice.
      adjMinLen = .greatestFiniteMagnitude
    } else {
      let lenADOverTanMinArcAngleRad = lenAD / tanMinArcAngleRad;
      adjMinLen = sqrt(lenAD * lenAD + pow(lenADOverTanMinArcAngleRad, 2)) - lenADOverTanMinArcAngleRad
    }
  } else {
    adjMinLen = 0
  }
  if abs(deltaY) > abs(deltaX) {
    adjMinLen = max(0, min(lenDE, maxLen))
  }

  let newLen = max(adjMinLen, min(lenDE, maxLen))
  if from.y == to.y {
    pointE2 = CGPoint(x: pointD.x, y: pointD.y + newLen)
  } else {
    let normalizedVDE = normalized(vDE)
    pointE2 = CGPoint(x: pointD.x + (normalizedVDE.x * newLen),
                      y: pointD.y + (normalizedVDE.y * newLen))
  }

  // Alpha'
  let lenDE2 = distance(from: pointD, to: pointE2)
  let alpha2 = atan(lenDE2 / lenAD)

  // Alpha' degrees.
  let alpha2deg = rad2deg(alpha2)

  // Beta' degrees.
  let beta2deg = 90.0 - alpha2deg

  // Beta'.
  let beta2 = deg2rad(beta2deg)

  // Radius'.
  let radius2 = lenAD / cos(beta2)

  // Calculate the cubic bezier tangent handle length
  //
  // The following method is for a 90 degree arc
  //
  // tangent length = radius * k * scaleFactor
  //
  // radius: radius of our circle
  // kappa: constant with value of ~0.5522847498
  // scaleFactor: proportion of our arc to a 90 degree arc (arc angle / 90)
  let kappa: CGFloat = 0.5522847498
  let radScaling: CGFloat = (alpha2deg * 2.0) / 90.0
  let tangentLength = radius2 * kappa * radScaling

  // Calculate the in tangent position in world coordinates
  // The tangent handle lies along the line between points B and E'
  // with magnitude of tangentLength
  let vBEnorm = normalized(CGPoint(x: pointE2.x - to.x, y: pointE2.y - to.y))
  let inTangent = CGPoint(x: to.x + (vBEnorm.x * tangentLength),
                          y: to.y + (vBEnorm.y * tangentLength))

  // Calculate the out tangent position in world coordinates
  // The tangent handle lies along the line between points A and E'
  // with magnitude of tangentLength
  let vAEnorm = normalized(CGPoint(x: pointE2.x - from.x, y: pointE2.y - from.y))
  let outTangent = CGPoint(x: from.x + (vAEnorm.x * tangentLength),
                           y: from.y + (vAEnorm.y * tangentLength))

  return ControlPoints(point1: outTangent, point2: inTangent)
}
