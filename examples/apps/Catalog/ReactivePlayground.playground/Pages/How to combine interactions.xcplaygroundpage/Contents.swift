/*:
 ## How to combine interactions

 Interactions are building blocks for complex motion. We can create new interactions by combining interactions in interesting ways. For example, *Tossable* is a combination of `Spring` and `Draggable`. Let's see how we might build Tossable from scratch.
 
 > This page includes many independent examples that need to be pasted into the playground in order to take effect.
 */
import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)
let runtime = MotionRuntime(containerView: canvas)

//: ---
//:
//: First we create the interactions we know we'll need: Spring and Draggable.
let spring = Spring<CGPoint>(threshold: 1, system: coreAnimation)
let draggable = Draggable()

//: Inspecting Draggable's documentation reveals that it will affect the view's layer position (Option-Click Draggable), so let's make sure we use the same property for our spring:
let position = runtime.get(view.layer).position

//: If we associate our interactions right now we'll notice something unsurprising: we can drag the view, but when we let go nothing happens. This is because we haven't combined the interactions in any way.
//:
//:     runtime.add(spring, to: position)
//:     runtime.add(draggable, to: view)

// Paste code here to try it out. Delete it before trying another example.

//: ---
//:
//: ### Toggling interactions
//:
//: Many interactions can be **toggled**. Togglable interactions can be disabled and enabled.
//:
//: When an interaction is **disabled** it will stop any motion associated with it. For example, when a spring is disabled it will stop moving toward its destination.
//:
//: When an interaction is **enabled** it will start moving again, often by re-initializing the animation with new initial values such as the current value of the property being affected.
//:
//: ---
//:
//: When we finish dragging we want our spring interaction to start animating, so this is a perfect use of toggling. We can create a toggling association between two interactions using `runtime.toggle`. Try pasting the following example into the playground.
//:
//:     runtime.toggle(spring, inReactionTo: draggable)
//:
//:     runtime.add(spring, to: position)
//:     runtime.add(draggable, to: view)

// Paste code here to try it out. Delete it before trying another example.

//:
//: You can now drag the view and, upon release, the view will snap back to its destination.
//:
//: > The default destination will always be the top-left corner of our canvas, so recall that we can use `SetPositionOnTap` to easily change the destination.
//:

runtime.add(SetPositionOnTap(coordinateSpace: canvas),
            to: spring.destination)

//:
//: You may have noticed that if you release while quickly dragging that the view doesn't appear to respect the final velocity of your gesture. Let's make this interaction more believable by connecting our draggable gesture's final velocity to our spring's **initial velocity**.
//:
//:     runtime.add(draggable.finalVelocity, to: spring.initialVelocity)
//:
//:     runtime.toggle(spring, inReactionTo: draggable)
//:     runtime.add(spring, to: position)
//:     runtime.add(draggable, to: view)

// Paste code here to try it out. Delete it before trying another example.

//:
//: > Order is important here: we want to ensure that our spring's initial velocity is configured before the spring is toggled by the draggable gesture, otherwise our spring won't have access to the velocity when it's re-enabled.
//:
//: We've now created the parts necessary for a `Tossable` interaction. We certainly don't want to have to remember to build these pieces every time we want an interaction like this, so on the next page we'll learn how to create new Interaction types.
//:
//: [Previous](@previous) - [Next](@next)

