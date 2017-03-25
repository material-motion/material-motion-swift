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

extension UIColor {
  private convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")

    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }

  convenience init(hexColor: Int) {
    self.init(red: (hexColor >> 16) & 0xff, green: (hexColor >> 8) & 0xff, blue: hexColor & 0xff)
  }

  static var primaryColor: UIColor {
    return UIColor(hexColor: 0xFF80AB)
  }

  static var secondaryColor: UIColor {
    return UIColor(hexColor: 0xC51162)
  }

  static var backgroundColor: UIColor {
    return UIColor(hexColor: 0x212121)
  }
}
