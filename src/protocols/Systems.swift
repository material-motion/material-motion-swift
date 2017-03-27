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
 A gesture-to-stream function creates a MotionObservable from a gesture recognizer.

 The stream is expected to dispatch the gesture recognizer each time its state is updated.
 */
public typealias GestureToStream<T: UIGestureRecognizer> = (T) -> MotionObservable<T>

public typealias PathTweenToStream<T> = (PathTweenShadow) -> MotionObservable<CGPoint>

/**
 A scrollview-to-stream function creates a MotionObservable from a UIScrollView.

 The stream is expected to dispatch changes of the scroll view's content offset.
 */
public typealias ScrollViewToStream = (UIScrollView) -> MotionObservable<CGPoint>

/** A tween-to-stream function creates a MotionObservable from a Tween. */
public typealias TweenToStream<T> = (TweenShadow<T>) -> MotionObservable<T>

/**
 Swift 3.1 does not allow generic typealiases to use protocol lists, so we define this composite
 type instead.
 */
public protocol ZeroableAndSubtractable: Zeroable, Subtractable {}

/**
 A spring-to-stream function creates a MotionObservable from a Spring and initial value stream.
 */
public typealias SpringToStream<T: ZeroableAndSubtractable> = (SpringShadow<T>) -> MotionObservable<T>
