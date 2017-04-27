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

/**
 A reactive representation of an object uses a global cache to fetch reactive property instances.

 Reactive property instances for a given object are shared across reactive instances. E.g.

     Reactive(view).position === Reactive(view).position // true

 ## Memory considerations

 - Reactive instances keep a strong reference to their object.
 - Reactive properties are weakly held by the global property cache.

 ## Extending this type

 Use protocol extensions to extend this type for specific object types. For example:

     extension Reactive where O: UIView {

       public var isUserInteractionEnabled: ReactiveProperty<Bool> {
         let view = _object
         return _properties.named(#function) {
           return .init(initialValue: view.isUserInteractionEnabled) {
             view.isUserInteractionEnabled = $0
           }
         }
       }
 */
public final class Reactive<O: AnyObject> {

  /**
   Creates a reactive representation of the given object.
   */
  public init(_ object: O) {
    self._object = object

    if let cache = globalCache.object(forKey: object) {
      self._properties = cache
    } else {
      let cache = ReactiveCache()
      globalCache.setObject(cache, forKey: object)
      self._properties = cache
    }
  }

  /**
   The object backing this reactive instance.
   */
  public let _object: O

  /**
   The property cache for this object instance.
   */
  public let _properties: ReactiveCache
}

/**
 A reactive cache is created for an object as weak storage for reactive properties.

 Properties can be queried by name. The cache does not keep a strong reference to the stored
 properties. If no references are kept to a queried property then it will be released and a new
 reactive property will be returned on a subsequent invocation.
 */
public final class ReactiveCache: CustomDebugStringConvertible {

  /**
   Queries a property with a given name, creating a new instance if no property exists yet.

   onCacheMiss is invoked if the property is not cached. The returned reactive property will be
   stored in the cache and returned.
   */
  func named<T>(_ name: String, onCacheMiss: () -> ReactiveProperty<T>) -> ReactiveProperty<T> {
    if let property = cache.object(forKey: name as NSString) {
      return property as! ReactiveProperty<T>
    }
    let property = onCacheMiss()
    cache.setObject(property, forKey: name as NSString)
    return property
  }

  // Reactive properties are weakly held because they hold a reference to the object. If we kept a
  // strong reference to the property then the globalCache weak key for the object would never reach
  // zero and we'd have a memory leak, even if the property, object, and reactive instance were all
  // dereferenced in client code.
  private let cache = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory,
                                                      valueOptions: [.weakMemory, .objectPointerPersonality])

  public var debugDescription: String {
    return cache.debugDescription
  }
}

private var globalCache = NSMapTable<AnyObject, ReactiveCache>(keyOptions: [.weakMemory, .objectPointerPersonality],
                                                               valueOptions: [.strongMemory, .objectPointerPersonality])
