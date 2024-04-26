//
//  String+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/26.
//

import Foundation

extension String: CompatibleValue {}
extension CompatibleWrapper where Base == String {
    
    /// lastPathComponent
    internal var lastPathComponent: String {
        return (base as NSString).lastPathComponent
    }
}
