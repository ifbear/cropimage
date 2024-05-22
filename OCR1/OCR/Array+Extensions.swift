//
//  Array+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/5/10.
//

import Foundation

extension Array {
    
    /// toDictionary
    /// - Returns: [T: Element]
    internal func toDictionary<T>(where selectKey: (Element) -> T) -> [T: Element] where T: Hashable {
        var dict: [T: Element] = [:]
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
    
    /// toDictionary
    /// - Parameter block: (Element) -> (key: Key, value: Value)
    /// - Returns: [Key: Value]
    internal func toDictionary<Key, Value>(where block: (Element) -> (key: Key, value: Value)) -> [Key: Value] where Key: Hashable, Value: Any {
        var dict: [Key: Value] = [:]
        for element in self {
            let kv = block(element)
            dict[kv.key] = kv.value
        }
        return dict
    }
    
    /// chunked
    /// - Parameter distance: Int
    /// - Returns: [[Element]]
    internal func chunked(by distance: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: distance).map {
            return Array(self[$0 ..< Swift.min($0 + distance, self.count)])
        }
    }
    
    /// subarray with range
    /// - Parameter range: NSRange
    /// - Returns: [Element]
    internal func subarray(with range: NSRange) -> [Element] {
        return (self as NSArray).subarray(with: range) as! [Element]
    }
    
    /// element at index
    /// - Parameter index: Int
    /// - Returns: Element
    internal func element(at index: Int) -> Element? {
        guard (0 ..< count).contains(index) == true else { return nil }
        return self[index]
    }
    
    /// excludes
    /// - Parameter isExcluded: (Element) throws -> Bool
    /// - Returns: [Element]
    internal func exclude(_ isExcluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try filter { return try isExcluded($0) == false }
    }
}

/// NSObject
extension Array where Element: NSObject {
    
    /// copy
    /// - Returns: [Element]
    internal func copy() -> [Element] {
        return self.compactMap { $0.copy() as? Element }
    }
}

extension Array where Element: Hashable {
    
    /// union
    /// - Parameter other: Array<Element>
    /// - Returns: Array<Element>
    internal func union(_ other: Array<Element>) -> Array<Element> {
        return Array(Set(self).union(other))
    }
    
    /// union
    /// - Parameter other: Element
    /// - Returns: Array<Element>
    internal func union(_ other: Element) -> Array<Element> {
        return Array(Set(self).union([other]))
    }
    
    /// subtracting
    /// - Parameter other:  Array<Element>
    /// - Returns:  Array<Element>
    internal func subtracting(_ other: Array<Element>) -> Array<Element> {
        return Array(Set(self).subtracting(other))
    }
    
    /// subtracting
    /// - Parameter other: Element
    /// - Returns: Array<Element>
    internal func subtracting(_ other: Element) -> Array<Element> {
        return Array(Set(self).subtracting([other]))
    }
    
}

extension Array: CompatibleValue {}
extension CompatibleWrapper where Base == Array<String> {
    
    /// uniqueArray
    /// - Returns: Array<String>
    internal func uniqueArray() -> Array<String> {
        var set: Set<String> = .init()
        return base.compactMap { element in
            let result = set.insert(element)
            return result.inserted == true ? result.memberAfterInsert : .none
        }
    }
}
