/*:
 ## How to create new interactions

 Once we've identified a combination of interactions that we feel is useful, it's time to create a new Interaction type representing these combinations.
 */
import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)
let runtime = MotionRuntime(containerView: canvas)

//: ---
//:
//: Start by defining a new class conforming to the Interaction protocol.
//:
//: > By convention, interactions are marked `final` unless there's a good reason to do otherwise.
final class MyTossable: Interaction {

//: Recall that Tossable is composed of two interactions: Draggable and Spring.
//:
//: > By convention, interactions should accept their composed interactions in the initializer. Store these interactions as `let` values on the class.
  let draggable: Draggable
  let spring: Spring<CGPoint>

  init(spring: Spring<CGPoint>, draggable: Draggable = Draggable()) {
    self.spring = spring
    self.draggable = draggable
  }

//: The Interaction protocol requires that we implement a single method: `add`. This method defines two generic types: the interaction's **value type** and the optional **constraint type**. This method will be invoked by the runtime when we call `runtime.add` with an instance of this interaction.
//:
//: In this case we want our interaction to be registered to instances of UIView and we won't support any constraints.
  func add(to target: UIView, withRuntime runtime: MotionRuntime, constraints: NoConstraints) {

//: Include the code we wrote in the previous page and our interaction is complete.

    let position = runtime.get(view.layer).position

    runtime.add(draggable.finalVelocity, to: spring.initialVelocity)

    runtime.toggle(spring, inReactionTo: draggable)
    runtime.add(spring, to: position)
    runtime.add(draggable, to: view)
  }
}

//: Using our new interaction is a matter of instantiating it and associating it with a view:

let tossable = MyTossable(spring: .init(threshold: 1, system: coreAnimation))
runtime.add(tossable, to: view)

runtime.add(SetPositionOnTap(coordinateSpace: canvas),
            to: tossable.spring.destination)

//: [Previous](@previous) - [Next](@next)
