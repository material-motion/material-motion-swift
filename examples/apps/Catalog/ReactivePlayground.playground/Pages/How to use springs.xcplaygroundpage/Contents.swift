/*:
 ## How to use springs

 A spring is an animation that pulls an object toward a destination.
 */
import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)
let runtime = MotionRuntime(containerView: canvas)

//: ---
//:
//: Spring interactions must be associated with **reactive properties**.
//:
//: A reactive property is like a traditional swift property, with an additional feature allowing other objects to **subscribe** to changes made to the property. We'll talk more about reactive properties in another page.
//:
//: In this example we'd like to animate the *position* of our example view, so let's retrieve that property.
//:
//: > `runtime.get` is the recommended way to create reactive properties for objects. This method can return reactive variants of `UIView`, `CALayer`, and `UIGestureRecognizer`.
let position = runtime.get(view.layer).position

//: Next we'll create our Spring interaction. We must specify the type of Spring we'd like to use because Spring is a [generic type](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html). In this case we want to animate a CGPoint, so we'll define that here:
let spring = Spring<CGPoint>(threshold: 1, system: coreAnimation)

//: Starting the spring animation is now a simple matter of adding it to the property:
runtime.add(spring, to: position)

//: A spring's destination is zero by default. We can see that this is the case because the view is centered on the top left corner of our canvas.
//:
//: Interactions often expose their own reactive properties. This lets us use interactions to control other interactions' behavior. In this case, Spring exposes a `destination` property.
//:
//: Let's try adding a `SetPositionOnTap` interaction to our spring's destination:
runtime.add(SetPositionOnTap(coordinateSpace: canvas), to: spring.destination)

//: We can now tap anywhere on the canvas to move the view.

//: [Previous](@previous) - [Next](@next)
