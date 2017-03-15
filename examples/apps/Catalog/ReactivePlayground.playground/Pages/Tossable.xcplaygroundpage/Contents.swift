/*:
 ## Reactive Motion tossable playground
 */
import ReactiveMotion

let canvas = createCanvas()

let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .blue
canvas.addSubview(view)

let target = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
target.backgroundColor = .white
target.layer.borderColor = UIColor.red.cgColor
target.layer.borderWidth = 1
canvas.insertSubview(target, belowSubview: view)

let runtime = MotionRuntime(containerView: canvas)
/*:
 ---

 This playground shows how to create a Tossable interaction with a reactive destination. Tappinng around will change the destination.
 */
let tossable = Tossable(system: coreAnimation)
let targetPosition = runtime.get(target.layer).position

runtime.add(SetPositionOnTap(coordinateSpace: canvas), to: targetPosition)
runtime.connect(targetPosition, to: tossable.spring.destination)

runtime.add(tossable, to: view) { $0.yLocked(to: 100) }
/*:
 ---
 */
visualize(graphviz: runtime.asGraphviz(), onCanvas: canvas)
