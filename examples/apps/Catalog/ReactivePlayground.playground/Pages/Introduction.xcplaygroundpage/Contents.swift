/*:
 ## Introduction to Material Motion

 A small, performant library for building reactive motion.
 */

import MaterialMotion

//: Material Motion includes a variety of ready-to-use **interactions**. An interaction is an object that can be associated with a view or property. Interactions take effect immediately upon association. In this introduction we'll associate a Draggable interaction with a view to make it respond to drag events.

// Basic scaffolding we'll use in all of our examples.
let view = createExampleView()
canvas.addSubview(view)

//: ---
//: Before we can associate any motion with our view we need to create a **runtime**.
//:
//: > A runtime's container view should be the top-most view for your interactions. In this case we're using our playground's canvas view, but in an app you might use a view controller's view.
let runtime = MotionRuntime(containerView: canvas)

//: Let's make the view draggable by adding a `Draggable` interaction to it.
runtime.add(Draggable(), to: view)

//: Try dragging the view around by opening the Assistant Editor and selecting the Timeline view.
//:
//: [Next](@next)
