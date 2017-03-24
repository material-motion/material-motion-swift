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
 A lerpable type is capable of calculating a linear interpolation from one vector to another.
 */
public protocol Lerpable {
  /**
   Returns the progress of this vector along a given vector.
   */
  func progress(along vector: Self) -> CGFloat

  /**
   Returns the result of multiplying the given progress along this vector.
   */
  func project(progress: CGFloat) -> Self
}

extension CGFloat: Lerpable {
  public func progress(along vector: CGFloat) -> CGFloat {
    if vector == 0 {
      return 0
    }
    return self / vector
  }

  public func project(progress: CGFloat) -> CGFloat {
    return self * progress
  }
}
