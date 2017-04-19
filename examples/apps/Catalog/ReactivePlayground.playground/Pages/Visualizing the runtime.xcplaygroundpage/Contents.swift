/*:
 ## Visualizing the runtime

 The motion runtime represents all of its interactions as **connected streams**, making it possible to visualize the internal state of the runtime as a directed graph. Use `runtime.asGraphviz()` to get a graphviz-compatible string for visualizing the runtime.

 In this page we'll use webgraphviz.com to visualize the runtime in our playground in real time.
 */
import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)
let runtime = MotionRuntime(containerView: canvas)

//: ---
//:
//: Try adding new interactions and constraints below.

runtime.add(Draggable(), to: view) { $0.xLocked(to: 100) }

//: ---

visualize(graphviz: runtime.asGraphviz(), onCanvas: canvas)
