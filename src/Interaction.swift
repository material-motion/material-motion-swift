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
 An interaction is responsible for associating one or more streams of information to a given target.

 A single instance of an Interaction may be associated with many distinct targets. This one-to-many
 behavior varies per-interaction and should be clearly documented by the concrete type.

 Properties on an interaction should either be constants or ReactiveProperty instances. Changes to a
 reactive property should affect all previously-associated targets.
 */
public protocol Interaction {
  associatedtype Target
  associatedtype Constraints

  /**
   Invoked when an interaction is added to a runtime.

   The conforming type defines the target and optional constraints types via this signature.

   Use Void? as the constraints type to indicate that the interaction does not support constraints.
   */
  func add(to target: Target, withRuntime runtime: MotionRuntime, constraints: Constraints?)
}

/**
 A typical constraint shape for an interaction.

 Accepts a stream and returns a stream of the same type. This is a convenient way to modify a stream
 with operators.
 */
public typealias ConstraintApplicator<T> = (MotionObservable<T>) -> MotionObservable<T>
