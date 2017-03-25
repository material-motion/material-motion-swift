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
 A transition is responsible for describing the motion that will occur during a UIViewController
 transition.
 */
public protocol Transition {
  /** Transition directors must be instantiable. */
  init()

  /**
   Invoked on initiation of a view controller transition.

   Must return a list of streams that will determine when this transition comes to rest.
   */
  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful]
}

/**
 A self-dismissing transition is given an opportunity to register gesture recognizers that will
 cause the presented view controller to be dismissed.
 */
public protocol SelfDismissingTransition: Transition {
  static func willPresent(fore: UIViewController, dismisser: ViewControllerDismisser)
}
