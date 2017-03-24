/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

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

import Foundation
import UIKit

public protocol Inspectable {
  var metadata: Metadata { get }
}

public final class Metadata: CustomDebugStringConvertible {
  enum Metatype {
    case node
    case constraint
    case property
    case constant
  }
  var type: Metatype
  let name: String
  let args: [Any]?
  let label: String
  var parent: Metadata?

  init(_ name: String? = nil, type: Metatype = .node, args: [Any]? = nil, parent: Metadata? = nil) {
    if let name = name {
      self.name = "\(name)(\(NSUUID().uuidString))"
      self.label = name
    } else {
      self.name = ""
      self.label = "Unnamed property"
    }
    self.args = args
    self.parent = parent
    self.type = type
  }

  init(_ metadata: Metadata, type: Metatype = .node, parent: Metadata) {
    self.name = metadata.name
    self.label = metadata.label
    self.args = metadata.args
    self.type = type
    self.parent = parent
  }

  func createChild(_ metadata: Metadata, type: Metatype = .node) -> Metadata {
    return Metadata(metadata, type: type, parent: self)
  }

  private var style: String {
    switch type {
    case .constraint:
      return "style=filled, fillcolor=\"#FF80AB\""
    case .node:
      return "style=filled, fillcolor=\"#FFFFFF\""
    case .property:
      return "style=filled, fillcolor=\"#C51162\""
    case .constant:
      return "style=filled, color=white fillcolor=\"#111111\""
    }
  }

  private func prettyLabel() -> String {
    var description: [String] = []
    if let args = args {
      var components = label.components(separatedBy: ":")
      for i in 0..<components.count {
        description.append(components[i])
        if !label.hasSuffix(")") && i == 0 {
          description.append("(")
        }
        if i < args.count {
          description.append(":\\n\(pretty(args[i]))")
        }
        if i < components.count - 2 {
          description.append(",\\n")
        }
      }
      if !label.hasSuffix(")") {
        description.append(")")
      }
    } else {
      description.append(label)
    }
    return description.joined()
  }

  public var debugDescription: String {
    var description: [String] = []

    var iterator = self
    while let parent = iterator.parent {
      description.append("{\"\(parent.name)\" [label=\"\(parent.prettyLabel())\", \(parent.style)]} -> {\"\(iterator.name)\" [label=\"\(iterator.prettyLabel())\", \(iterator.style)]}")

      iterator = parent

      // If any arguments have metadata associated with them then we create a temporary association
      // between the arg and this iterator and describe that graph.
      if let args = iterator.args {
        for arg in args {
          if let inspectable = arg as? Inspectable {
            let metadata = inspectable.metadata.createChild(iterator)
            description.append(metadata.debugDescription)
          }
        }
      }
    }

    return description.joined(separator: "\n").replacingOccurrences(of: "MaterialMotion.", with: "")
  }
}

func pretty(_ object: Any) -> String {
  switch object {
  case is String: fallthrough
  case is Int: fallthrough
  case is Bool: fallthrough
  case is Double: fallthrough
  case is CGFloat: fallthrough
  case is UIColor: fallthrough
  case is UIGestureRecognizerState: fallthrough
  case is Float:
    return "\(object)"

  case let object as Array<Any>:
    return object.map(pretty).joined(separator: ", ")

  case let object as NSObject:
    return "\(type(of: object))::\(pretty(ObjectIdentifier(object)))"

  case let object as AnyObject:
    return "\(object)::\(pretty(ObjectIdentifier(object)))"

  default:
    return "\(object)"
  }
}

func pretty(_ objectIdentifer: ObjectIdentifier) -> String {
  return objectIdentifer.debugDescription
    .replacingOccurrences(of: "ObjectIdentifier(0x0000", with: "0x")
    .replacingOccurrences(of: ")", with: "")
}

extension UIGestureRecognizerState: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .began: return ".began"
    case .changed: return ".changed"
    case .cancelled: return ".cancelled"
    case .ended: return ".ended"
    case .possible: return ".possible"
    case .failed: return ".failed"
    }
  }
}
