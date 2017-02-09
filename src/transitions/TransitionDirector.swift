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

/**
 A transition director is responsible for describing the motion that will occur during a
 UIViewController transition.
 */
public protocol TransitionDirector {
  /** Transition directors must be instantiable. */
  init()

  /** Invoked on initiation of a view controller transition. */
  func willBeginTransition(_ transition: Transition, runtime: MotionRuntime)
}

/**
 A self-dismissing director is given an opportunity to register gesture recognizers that will
 cause the presented view controller to be dismissed.
 */
public protocol SelfDismissingTransitionDirector: TransitionDirector {
  static func willPresent(fore: UIViewController, dismisser: ViewControllerDismisser)
}

public class SimpleTransitionDirector: NSObject, TransitionDirector {
  required public override init() {
    super.init()
  }
  public func willBeginTransition(_ transition: Transition, runtime: MotionRuntime) {

  }
}
