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

/** A Transition represents the essential state for a UIViewController transition. */
public class Transition: NSObject {

  /** The default duration for a view controller transition. */
  public static let defaultDuration: TimeInterval = 0.35

  /** The possible directions of a transition. */
  public enum Direction {
    /** The fore view controller is being presented. */
    case forward

    /** The fore view controller is being dismissed. */
    case backward
  }

  /** The direction this transition is moving in. */
  public let direction: ReactiveProperty<Direction>

  /** The transition window for this transition. */
  public let window: TransitionTimeWindow

  /** The context view for this transition. */
  public func contextView() -> UIView {
    return UIView() // TODO: Lazily fetch this
  }

  /** The container view for the transition as reported by UIKit's transition context. */
  public func containerView() -> UIView {
    return context.containerView
  }

  /**
   The back view controller for this transition.

   This is the destination when the transition's direction is backward.
   */
  public let back: UIViewController

  /**
   The fore view controller for this transition.

   This is the destination when the transition's direction is forward.
   */
  public let fore: UIViewController

  /** The runtime to which motion should be registered. */
  public fileprivate(set) var runtime: MotionAggregator!

  weak var delegate: TransitionDelegate?

  init(directorType: TransitionDirector.Type, direction: Direction, back: UIViewController, fore: UIViewController) {
    self.direction = createProperty(withInitialValue: direction)
    self.initialDirection = direction
    self.back = back
    self.fore = fore
    self.window = TransitionTimeWindow(duration: Transition.defaultDuration)

    // TODO: Create a Timeline.

    self.runtime = MotionAggregator()

    self.director = directorType.init()

    super.init()

    self.runtime!.delegate = self
  }

  fileprivate let initialDirection: Direction
  fileprivate var director: TransitionDirector!
  fileprivate var context: UIViewControllerContextTransitioning!

  private var _contextView: UIView?
}

extension Transition: UIViewControllerAnimatedTransitioning {
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return window.duration
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    context = transitionContext

    initiateTransition()
  }

  public func animationEnded(_ transitionCompleted: Bool) {
    fore.view.isUserInteractionEnabled = true
    back.view.isUserInteractionEnabled = true
  }
}

extension Transition: UIViewControllerInteractiveTransitioning {
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    context = transitionContext

    initiateTransition()
  }
}

extension Transition: MotionAggregatorDelegate {
  public func motionAggregateStateDidChange(_ motionAggregate: MotionAggregator) {
    if motionAggregate.aggregateState == .atRest {
      runtimeDidComeToRest()
    }
  }
}

extension Transition {
  fileprivate func initiateTransition() {
    if let from = context.viewController(forKey: .from) {
      from.view.isUserInteractionEnabled = false

      let finalFrame = context.finalFrame(for: from)
      if !finalFrame.isEmpty {
        from.view.frame = finalFrame
      }
    }

    if let to = context.viewController(forKey: .to) {
      to.view.isUserInteractionEnabled = false

      let finalFrame = context.finalFrame(for: to)
      if !finalFrame.isEmpty {
        to.view.frame = finalFrame
      }

      switch direction.read() {
      case .forward:
        context.containerView.addSubview(to.view)

      case .backward:
        if to.view.superview == nil {
          context.containerView.insertSubview(to.view, at: 0)
        }
      }
    }

    director.willBeginTransition(self)

    // TODO: Provide the director with gesture recognizers.

    // If no motion was registered to the runtime then we terminate immediately.
    if runtime.aggregateState == .atRest {
      runtimeDidComeToRest()
    }
  }

  fileprivate func runtimeDidComeToRest() {
    let completedInOriginalDirection = direction.read() == initialDirection

    // UIKit container view controllers will replay their transition animation if the transition
    // percentage is exactly 0 or 1, so we fake being super close to these values in order to avoid
    // this flickering animation.
    if completedInOriginalDirection {
      context.updateInteractiveTransition(0.999)
      context.finishInteractiveTransition()
    } else {
      context.updateInteractiveTransition(0.001)
      context.cancelInteractiveTransition()
    }
    context.completeTransition(completedInOriginalDirection)

    runtime = nil
    director = nil

    delegate?.transitionDidComplete(self)
  }
}

protocol TransitionDelegate: NSObjectProtocol {
  func transitionDidComplete(_ transition: Transition)
}
