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
import IndefiniteObservable

/**
 The possible directions of a transition.
 */
public enum TransitionDirection {
  /**
   The fore view controller is being presented.
   */
  case forward

  /**
   The fore view controller is being dismissed.
   */
  case backward
}

/** A Transition represents the essential state for a UIViewController transition. */
public final class TransitionContext: NSObject {

  /** The default duration for a view controller transition. */
  public static let defaultDuration: TimeInterval = 0.35

  /** The direction this transition is moving in. */
  public let direction: ReactiveProperty<TransitionDirection>

  /** The transition window for this transition. */
  public let window: TransitionTimeWindow

  public let replicator = ViewReplicator()

  /** The context view for this transition. */
  public func contextView() -> UIView? {
    if contextViewRetriever == nil {
      // transitionContextViewRetriever can be a relatively complex lookup if it can't
      // immediately find the context view retriever, thus the lazy lookup here.
      contextViewRetriever = transitionContextViewRetriever(for: back)
    }
    if hasFetchedContextView {
      return _contextView
    }
    hasFetchedContextView = true
    _contextView = contextViewRetriever!.contextViewForTransition(foreViewController: fore)
    return _contextView
  }
  private var contextViewRetriever: TransitionContextViewRetriever?
  private var hasFetchedContextView = false
  private var _contextView: UIView?

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

  /** The set of gesture recognizers associated with this transition. */
  public let gestureRecognizers: Set<UIGestureRecognizer>

  /** The runtime to which motion should be registered. */
  fileprivate var runtime: MotionRuntime!

  fileprivate let presentationController: UIPresentationController?

  weak var delegate: TransitionDelegate?

  init(transition: Transition,
       direction: TransitionDirection,
       back: UIViewController,
       fore: UIViewController,
       gestureRecognizers: Set<UIGestureRecognizer>,
       presentationController: UIPresentationController?) {
    self.direction = createProperty(withInitialValue: direction)
    self.initialDirection = direction
    self.back = back
    self.fore = fore
    self.gestureRecognizers = gestureRecognizers
    self.window = TransitionTimeWindow(duration: TransitionContext.defaultDuration)
    self.presentationController = presentationController

    self.transition = transition

    super.init()
  }

  fileprivate let initialDirection: TransitionDirection
  fileprivate var transition: Transition!
  fileprivate var context: UIViewControllerContextTransitioning!
  fileprivate var didRegisterTerminator = false
  fileprivate var interactiveSubscription: Subscription?
  fileprivate var isBeingManipulated = false
}

extension TransitionContext: UIViewControllerAnimatedTransitioning {
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return window.duration
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    context = transitionContext

    initiateTransition()
  }

  public func animationEnded(_ transitionCompleted: Bool) {
  }
}

extension TransitionContext: UIViewControllerInteractiveTransitioning {
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    context = transitionContext

    initiateTransition()
  }
}

extension TransitionContext {
  fileprivate func initiateTransition() {
    if let from = context.viewController(forKey: .from) {
      let finalFrame = context.finalFrame(for: from)
      if !finalFrame.isEmpty {
        from.view.frame = finalFrame
      }
    }

    if let to = context.viewController(forKey: .to) {
      let finalFrame = context.finalFrame(for: to)
      if !finalFrame.isEmpty {
        to.view.frame = finalFrame
      }

      switch direction.value {
      case .forward:
        context.containerView.addSubview(to.view)

      case .backward:
        if to.view.superview == nil {
          context.containerView.insertSubview(to.view, at: 0)
        }
      }
      to.view.layoutIfNeeded()
    }

    self.runtime = MotionRuntime(containerView: containerView())
    self.replicator.containerView = containerView()

    // We query the fallback just before initiating the transition so that the transition context is
    // primed with the content view and other transition-related information.
    while let fallbackTransition = self.transition as? TransitionWithFallback {
      let fallback = fallbackTransition.fallbackTansition(withContext: self)
      if fallback === self.transition {
        break
      }
      self.transition = fallback
    }

    pokeSystemAnimations()

    var terminators = transition.willBeginTransition(withContext: self, runtime: self.runtime)

    if let presentationController = presentationController as? Transition {
      terminators.append(contentsOf: presentationController.willBeginTransition(withContext: self,
                                                                                runtime: self.runtime))
    }

    runtime.whenAllAtRest(terminators) { [weak self] in
      self?.terminate()
    }

    observeInteractiveState()
  }

  // UIKit transitions will not animate any of the system animations (status bar changes, notably)
  // unless we have at least one implicit UIView animation. Material Motion doesn't use implicit
  // animations out of the box, so to ensure that system animations still occur we create an
  // invisible throwaway view and apply an animation to it.
  private func pokeSystemAnimations() {
    let throwawayView = UIView()
    containerView().addSubview(throwawayView)
    UIView.animate(withDuration: transitionDuration(using: context), animations: {
      throwawayView.frame = throwawayView.frame.offsetBy(dx: 1, dy: 0)
    }, completion: { didComplete in
      throwawayView.removeFromSuperview()
    })
  }

  // UIKit view controller transitions are either animated or interactive and we must inform UIKit
  // when this state changes. Certain system animations (status bar) will not be initiated until
  // interactivity has completed. We consider an "interactive transition" to be one that has one or
  // more active Manipulation types.
  private func observeInteractiveState() {
    interactiveSubscription = runtime.isBeingManipulated.dedupe().subscribeToValue { [weak self] isBeingManipulated in
      guard let strongSelf = self else {
        return
      }
      strongSelf.isBeingManipulated = isBeingManipulated

      // Becoming interactive
      if !strongSelf.context.isInteractive && isBeingManipulated {
        if #available(iOS 10.0, *) {
          strongSelf.context.pauseInteractiveTransition()
        }

      // Becoming non-interactive
      } else if strongSelf.context.isInteractive && !isBeingManipulated {
        let completedInOriginalDirection = strongSelf.direction.value == strongSelf.initialDirection
        if completedInOriginalDirection {
          strongSelf.context.finishInteractiveTransition()
        } else {
          strongSelf.context.cancelInteractiveTransition()
        }
      }
    }
  }

  private func terminate() {
    guard runtime != nil else { return }
    let completedInOriginalDirection = direction.value == initialDirection

    // UIKit container view controllers will replay their transition animation if the transition
    // percentage is exactly 0 or 1, so we fake being super close to these values in order to avoid
    // this flickering animation.
    if context.isInteractive {
      if completedInOriginalDirection {
        context.updateInteractiveTransition(0.999)
        context.finishInteractiveTransition()
      } else {
        context.updateInteractiveTransition(0.001)
        context.cancelInteractiveTransition()
      }
    }
    context.completeTransition(completedInOriginalDirection)

    if let transitionWithTermination = transition as? TransitionWithTermination {
      transitionWithTermination.didEndTransition(withContext: self, runtime: runtime)
    }

    runtime = nil
    transition = nil

    delegate?.transitionDidComplete(withContext: self)
  }
}

protocol TransitionDelegate: class {
  func transitionDidComplete(withContext ctx: TransitionContext)
}

extension TransitionDirection: Invertible {
  public func inverted() -> TransitionDirection {
    return self == .forward ? .backward : .forward
  }
}
