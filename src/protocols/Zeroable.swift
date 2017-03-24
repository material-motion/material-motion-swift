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
 A type that is able to instantiate a zero representation of itself.
 */
public protocol Zeroable {
  associatedtype T
  static func zero() -> T
}

extension CGPoint: Zeroable {
  public static func zero() -> CGPoint {
    return .zero
  }
}

extension CGSize: Zeroable {
  public static func zero() -> CGSize {
    return .zero
  }
}

extension CGRect: Zeroable {
  public static func zero() -> CGRect {
    return .zero
  }
}

extension CGFloat: Zeroable {
  public static func zero() -> CGFloat {
    return 0
  }
}
