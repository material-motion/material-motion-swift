/*:
 ## How to apply constraints

 Constraints can be applied to interactions in order to modify their behavior. A constraint receives values, does something with them, and emits values of the same type.
 */
import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)
let runtime = MotionRuntime(containerView: canvas)
let draggable = Draggable()

//: ---

//: Constraints are added to an interaction via the `runtime.add` API. The last argument to runtime.add is the optional constraint argument. In long-form, we might write a constraint like so:
//:
//:     runtime.add(draggable, to: view, constraints: { $0.log() })
//:
//: When a method's last argument is a block in Swift, we can drop the named parameter and use the following short-hand instead:
//:
//:     runtime.add(draggable, to: view) { $0.log() }
//:
//: We'll generally prefer this short-hand when using constraints throughout the examples.
//:
//: The first constraint you'll likely become familiar with is `log()`. This constraint writes anything it receives to the console.
//:
//: Try out these other constraints to see their effect on the interaction:
//:
//:     runtime.add(draggable, to: view) { $0.log() }
//:     runtime.add(draggable, to: view) { $0.xLocked(to: 100) }
//:     runtime.add(draggable, to: view) { $0.yLocked(to: 100) }

runtime.add(draggable, to: view) { $0.log() }

//: [Previous](@previous) - [Next](@next)
