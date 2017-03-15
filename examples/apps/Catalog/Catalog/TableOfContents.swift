/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

// MARK: Catalog by convention

import Foundation

extension DraggableExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Draggable"] }
}

extension DraggableConstraintExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Draggable with constraints"] }
}

extension DraggableCustomOperatorExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Draggable with custom operator"] }
}

extension DraggableReactiveConstraintExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Draggable with reactive constraints"] }
}

extension DirectlyManipulableExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Directly manipulable"] }
}

extension ArcMoveExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Arc move"] }
}

extension CarouselExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Carousel"] }
}

extension ModalDialogExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Modal dialog"] }
}

extension ContextualTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Contextual transition"] }
}

extension FabTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["FAB transition"] }
}

extension PushBackTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Push back transition"] }
}

extension InteractivePushBackTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Push back transition (interactive)"] }
}

extension StickerPickerExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Sticker picker"] }
}
