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
public protocol Transition: class {
  /**
   Invoked on initiation of a view controller transition.

   Must return a list of streams that will determine when this transition comes to rest.
   */
  func willBeginTransition(withContext ctx: TransitionContext, runtime: MotionRuntime) -> [Stateful]
}

/**
 A transition can return an alternative fallback transition instance.
 */
public protocol TransitionWithFallback: Transition {
  /**
   Invoked before the transition begins.

   If the returned instance also conforms to TransitionWithFallback, then the returned instance's
   fallback will be queried. This repeats until a returned instance does not conform to
   TransitionWithFallback or it returns self.
   */
  func fallbackTansition(withContext ctx: TransitionContext) -> Transition
}

/**
 A transition is responsible for describing the motion that will occur during a UIViewController
 transition.
 */
public protocol TransitionWithTermination: Transition {
  /**
   Invoked on completion of a view controller transition.
   */
  func didEndTransition(withContext ctx: TransitionContext, runtime: MotionRuntime)
}

/**
 A transition with presentation is able to customize the overall presentation of the transition,
 including adding temporary views and changing the destination frame of the presented view
 controller.
 */
public protocol TransitionWithPresentation: Transition {

  /**
   The modal presentation style this transition expects to use.

   This value is queried when the transition is assigned to a view controller's
   transitionController. The result, if any, is assigned to the view controller's
   modalPresentationStyle property.

   In order for a presentationController to be used, this method should return `.custom`.
   */
  func defaultModalPresentationStyle() -> UIModalPresentationStyle?

  /**
   Queried before the Transition object is instantiated and only once, when the fore view controller
   is initially presented.

   The returned object is cached for the lifetime of the fore view controller.

   The returned presentation controller may choose to conform to WillBeginTransition in order to
   associate reactive motion with the transition.

   If nil is returned then no presentation controller will be used.
   */
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController?
}

/**
 A self-dismissing transition is given an opportunity to register gesture recognizers that will
 cause the presented view controller to be dismissed.
 */
public protocol SelfDismissingTransition: Transition {
  func willPresent(fore: UIViewController, dismisser: ViewControllerDismisser)
}
