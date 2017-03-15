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

extension CarouselExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Case studies", "Carousel"] }
}

extension FabTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Case studies", "FAB transition"] }
}

extension StickerPickerExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Case studies", "Sticker picker"] }
}

extension HowToUseConstraintsExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["How to...", "Use constraints"] }
}

extension HowToUseReactiveConstraintsExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["How to...", "Use reactive constraints"] }
}

extension HowToMakeACustomOperatorExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["How to...", "Make a custom operator"] }
}

extension ArcMoveExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Interactions", "Arc move"] }
}

extension DraggableExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Interactions", "Draggable"] }
}

extension DirectlyManipulableExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Interactions", "Directly manipulable"] }
}

extension ModalDialogExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Transitions", "Modal dialog"] }
}

extension ContextualTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Transitions", "Contextual transition"] }
}

extension PushBackTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Transitions", "Push back transition"] }
}

extension InteractivePushBackTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] { return ["Transitions", "Push back transition (interactive)"] }
}
