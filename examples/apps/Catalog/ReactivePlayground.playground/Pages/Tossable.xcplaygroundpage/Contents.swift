//: [Previous](@previous)

import MaterialMotion

let view = createExampleView()
canvas.addSubview(view)

let target = createExampleView()
target.layer.borderColor = target.backgroundColor!.cgColor
target.layer.borderWidth = 1
target.backgroundColor = .white
canvas.insertSubview(target, belowSubview: view)

let runtime = MotionRuntime(containerView: canvas)

//: ---

/*:
 This playground shows how to create a Tossable interaction with a reactive destination. Tappinng around will change the destination.
 */
let tossable = Tossable()
let targetPosition = runtime.get(target.layer).position

runtime.add(SetPositionOnTap(coordinateSpace: canvas), to: targetPosition)
runtime.connect(targetPosition, to: tossable.spring.destination)

runtime.add(tossable, to: view) { $0.yLocked(to: 100) }

//: ---

visualize(graphviz: runtime.asGraphviz(), onCanvas: canvas)
