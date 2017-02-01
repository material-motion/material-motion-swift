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

import MaterialMotionStreams

@available(iOS 9.0, *)
extension DragSourceExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Drag source"]
  }
}

extension ModalDialogExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Modal dialog"]
  }
}

@available(iOS 9.0, *)
extension ContextualTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Contextual transition"]
  }
}

@available(iOS 9.0, *)
extension PushBackTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Push back transition"]
  }
}

@available(iOS 9.0, *)
extension InteractivePushBackTransitionExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Push back transition (interactive)"]
  }
}

extension SwipeExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Swipe stack"]
  }
}

extension DirectlyManipulableExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Directly manipulable"]
  }
}
