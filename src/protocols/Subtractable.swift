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
 A subtractable type is able to subtract another instance of its type from itself.
 */
public protocol Subtractable {
  static func - (left: Self, right: Self) -> Self
}

extension CGPoint: Subtractable {
  public static func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return .init(x: left.x - right.x, y: left.y - right.y)
  }
}

extension CGSize: Subtractable {
  public static func -(left: CGSize, right: CGSize) -> CGSize {
    return .init(width: left.width - right.width, height: left.height - right.height)
  }
}

extension CGRect: Subtractable {
  public static func -(left: CGRect, right: CGRect) -> CGRect {
    return .init(x: left.origin.x - right.origin.x,
                 y: left.origin.y - right.origin.y,
                 width: left.width - right.width,
                 height: left.height - right.height)
  }
}

extension CGFloat: Subtractable {}
