//: [Previous](@previous)

import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)
let runtime = MotionRuntime(containerView: canvas)

//: ---
//:
//: Spring interactions must be associated with **reactive properties** and are strongly-typed. The most common types of Spring you'll create are `Spring<CGFloat>` and `Spring<CGPoint>`.
//:
//: In this example we'll animate the *position* of our example view, so let's create a `CGPoint` spring.
let spring = Spring<CGPoint>(threshold: 1, system: coreAnimation)

//: Our spring has to be added to a reactive property of type `CGPoint`.
//: > `runtime.get` is the recommended way to create reactive properties for objects. This method can return reactive variants of `UIView`, `CALayer`, and `UIGestureRecognizer`.
//:
//: Let's animate the view's layer position:
runtime.add(spring, to: runtime.get(view.layer).position)

//: A spring's destination is zero by default. We can see that this is the case because the view is centered on the top left corner of our canvas.
//:
//: Interactions often expose their own reactive properties. This lets us use interactions to control other interactions' behavior. Let's try adding a `SetPositionOnTap` interaction to our spring's destination:
runtime.add(SetPositionOnTap(coordinateSpace: canvas), to: spring.destination)

//: Try tapping anywhere on the canvas to move the view.

//: [Next](@next)
