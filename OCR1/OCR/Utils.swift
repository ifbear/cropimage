//
//  Utils.swift
//  OCR
//
//  Created by dexiong on 2024/5/7.
//

import Foundation
class Utils {}

extension Utils {
    
    /// synchronized
    /// - Parameters:
    ///   - obj: Any
    ///   - block: block: () -> T
    /// - Returns: T
    internal static func synchronized<T>(for obj: Any, block: () throws -> T) rethrows -> T {
        do {
            objc_sync_enter(obj)
            let element = try block()
            objc_sync_exit(obj)
            return element
        } catch {
            objc_sync_exit(obj)
            throw error
        }
    }
}
