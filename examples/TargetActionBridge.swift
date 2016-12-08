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

import UIKit
import IndefiniteObservable
import MaterialMotionStreams

// This example shows how to connect a target/selector-based event system to MotionObservable.
// There are two concepts introduced here: Source and Producer.

// A source is the beginning of a stream. It produces events by connecting one system to another.
// The source we create here will allow someone to subscribe to UITapGestureRecognizer events, so
// we'll call it tapSource.

func tapSource(_ gesture: UITapGestureRecognizer) -> MotionObservable<TapSubscription.Value> {
  return MotionObservable { observer in
    let subscription = TapSubscription(subscribedTo: gesture, observer: observer)
    return {
      subscription.unsubscribe()
    }
  }
}

// Sources represent the connection from an external system into Material Motion. Subscriptions are
// the literal connections. In this case our TapSubscription listens to UITapGestureRecognizer
// vents and sends them through the provided observer’s channels.

final class TapSubscription: Subscription {
  typealias Value = CGPoint

  init(subscribedTo gesture: UITapGestureRecognizer, observer: MotionObserver<Value>) {
    self.gesture = gesture
    self.observer = observer

    gesture.addTarget(self, action: #selector(didTap))

    // Populate the observer with the current gesture state.
    propagate()
  }

  func unsubscribe() {
    gesture?.removeTarget(self, action: #selector(didTap))
    gesture = nil
  }

  @objc private func didTap() {
    propagate()
  }

  private func propagate() {
    if gesture!.state != .recognized {
      return
    }
    // We simulate an instantaneous active state here:
    observer.state(.active)
    observer.next(value())
    observer.state(.atRest)
  }

  private func state() -> MotionState {
    return gesture!.state == .recognized ? .active : .atRest
  }

  private func value() -> Value {
    return gesture!.location(in: gesture!.view!)
  }

  private var gesture: (UITapGestureRecognizer)?
  private let observer: MotionObserver<Value>
}

public class TargetActionBridgeExampleViewController: UIViewController {

  var tapSubscription: Subscription?
  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let label = UILabel(frame: view.bounds)
    label.text = "Tap to view location"
    label.textAlignment = .center
    view.addSubview(label)

    let gesture = UITapGestureRecognizer()
    view.addGestureRecognizer(gesture)

    tapSubscription = tapSource(gesture).subscribe(next: { value in
      label.text = "\(value)"
    }, state: { state in
      print("State did change to \(state)")
    })
  }
}
