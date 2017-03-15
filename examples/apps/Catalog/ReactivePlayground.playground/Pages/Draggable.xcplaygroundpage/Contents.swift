/*:
 ## Reactive Motion playground

 Reactive motion is a runtime for building motion systems.

 The primary unit of motion is the Interaction, an instantiable object that can be associated with views or properties. In this example we'll make a view draggable by associating a Draggable interaction with it.
 */
import ReactiveMotion

let canvas = createCanvas()

let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .blue
canvas.addSubview(view)

/*: --- */

/*:
 A motion runtime associates motion with views and properties.
 */
let runtime = MotionRuntime(containerView: canvas)
/*:
 We make the view draggable by assocating an instance of Draggable with it.
 */
runtime.add(Draggable(), to: view)
/*:
 A runtime can generate a graphviz representation of itself at any time in order to visualize the flow of information.
 */
visualize(graphviz: runtime.asGraphviz(), onCanvas: canvas)
