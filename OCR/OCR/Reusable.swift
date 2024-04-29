//
//  Reusable.swift
//  OCR
//
//  Created by dexiong on 2024/4/29.
//

import Foundation

/// Reusable
protocol Reusable: AnyObject {
    /// 复用ID
    static var reusedID: String { get }
}

extension Reusable {
    
    /// 复用ID
    internal static var reusedID: String {
        return "\(self)"
    }
}
