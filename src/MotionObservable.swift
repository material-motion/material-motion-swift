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

import Foundation
import IndefiniteObservable

// Channels are functions that pass values down the stream.
public typealias NextChannel<T> = (T) -> Void
public typealias StateChannel = (MotionState) -> Void

/**
 A MotionObservable is a type of [Observable](http://reactivex.io/documentation/observable.html)
 that specializes in motion systems that can be either active or at rest.

 Throughout this documentation we will treat the words "observable" and "stream" as synonyms.
 */
public final class MotionObservable<T>: IndefiniteObservable<MotionObserver<T>>, ExtendableMotionObservable, Inspectable {
  public let metadata: Metadata

  public init(_ metadata: Metadata, connect: @escaping Connect<MotionObserver<T>>) {
    self.metadata = metadata
    super.init(connect)
  }

  private override convenience init(_ connect: @escaping Connect<MotionObserver<T>>) {
    self.init(Metadata("Invalid", label: "Invalid"), connect: connect)
  }

  /** Sugar for subscribing a MotionObserver. */
  public func subscribe(next: @escaping NextChannel<T>, state: @escaping StateChannel) -> Subscription {
    return super.subscribe(observer: MotionObserver<T>(next: next, state: state))
  }
}

public protocol Inspectable {
  var metadata: Metadata { get }
}

public final class Metadata: CustomDebugStringConvertible {
  public let name: String
  public let label: String
  public let args: [Any]?
  public var uuid = NSUUID().uuidString
  public var parent: Metadata?

  init(_ name: String, label: String? = nil, args: [Any]? = nil, parent: Metadata? = nil) {
    self.name = name
    if let label = label {
      self.label = label
    } else {
      self.label = name
    }
    self.args = args
    self.parent = parent
  }
  init(_ name: String, parent: Metadata) {
    self.name = name
    self.label = name
    self.args = nil
    self.parent = parent
  }

  public func with(_ name: String, args: [Any]? = nil) -> Metadata {
    return .init(name, label: name, args: args, parent: self)
  }

  public func with(_ name: String, label: String, args: [Any]? = nil) -> Metadata {
    return .init(name, label: label, args: args, parent: self)
  }

  private func prettyArgs() -> String {
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

    var lastunique: String = ""
    var iterator = self
    while let parent = iterator.parent {

      let unique: String
      if parent.parent != nil {
        // This is a "middle" node and needs to be uniqued.
        unique = parent.uuid
      } else {
        unique = ""
      }

      description.append("{\"\(parent.name)\(unique)\" [label=\"\(parent.prettyArgs())\"]} -> {\"\(iterator.name)\(lastunique)\" [label=\"\(iterator.prettyArgs())\"]}")

      if let args = parent.args {
        for arg in args {
          if let inspectable = arg as? Inspectable {
            let metadata = inspectable.metadata.with(parent.name, label: parent.label, args: parent.args)
            metadata.uuid = parent.uuid
            description.append(metadata.debugDescriptionWithLast)
          }
        }
      }

      lastunique = unique
      iterator = parent
    }

    return description.joined(separator: "\n").replacingOccurrences(of: "MaterialMotionStreams.", with: "")
  }

  public var debugDescriptionWithLast: String {
    var description: [String] = []

    var iterator = self
    while let parent = iterator.parent {

      description.append("{\"\(parent.name)\(parent.uuid)\" [label=\"\(parent.prettyArgs())\"]} -> {\"\(iterator.name)\(iterator.uuid)\" [label=\"\(iterator.prettyArgs())\"]}")

      if let args = parent.args {
        for arg in args {
          if let inspectable = arg as? Inspectable {
            let metadata = inspectable.metadata.with(parent.name, label: parent.label, args: parent.args)
            metadata.uuid = parent.uuid
            description.append(metadata.debugDescriptionWithLast)
          }
        }
      }

      iterator = parent
    }

    return description.joined(separator: "\n").replacingOccurrences(of: "MaterialMotionStreams.", with: "")
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

/**
 The possible states that a stream can be in.

 What "active" means is stream-dependant. The stream is active if you can answer yes to any of the
 following questions:

 - Is my animation currently animating?
 - Is my physical simulation still moving?
 - Is my gesture recognizer in the .began or .changed state?

 Momentary events such as taps may emit .active immediately followed by .atRest.
 */
public enum MotionState {
  /** The stream is at rest. */
  case atRest

  /** The stream is currently in motion. */
  case active
}

/** A MotionObserver receives values and state updates from a MotionObservable subscription. */
public final class MotionObserver<T>: Observer {
  public typealias Value = T

  public init(next: @escaping NextChannel<T>, state: @escaping StateChannel) {
    self.next = next
    self.state = state
  }

  public let next: NextChannel<T>
  public let state: StateChannel
}

/**
 This type is used for extending MotionObservable using generics.

 This is required to be able to do extensions where T == some value, such as CGPoint. See
 https://twitter.com/dgregor79/status/646167048645554176 for discussion of what appears to be a
 bug in swift.
 */
public protocol ExtendableMotionObservable {
  associatedtype T

  var metadata: Metadata { get }

  /**
   We define this only so that T can be inferred by the compiler so that we don't have to
   introduce a new generic type such as Value in the associatedtype here.
   */
  func subscribe(next: @escaping NextChannel<T>, state: @escaping StateChannel) -> Subscription
}
