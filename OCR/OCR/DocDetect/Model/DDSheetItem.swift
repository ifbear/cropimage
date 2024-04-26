//
//  DDSheetItem.swift
//  OCR
//
//  Created by dexiong on 2024/4/26.
//

import Foundation

/// DDSheetItem
struct DDSheetItem: Hashable {
    internal let tag: Int
    internal let title: String
    internal let text: String

    
    /// hash
    /// - Parameter hasher: Hasher
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
}


extension DDSheetItem {
    
    /// 图片
    internal static var image: DDSheetItem { .init(tag: 1001 ,title: "图片", text: "") }
    /// PDF
    internal static var pdf: DDSheetItem { .init(tag: 2001 ,title: "PDF", text: "") }
    /// Word
    internal static var word: DDSheetItem { .init(tag: 3001 ,title: "Word", text: "(会员特权)") }
    /// PPT
    internal static var ppt: DDSheetItem { .init(tag: 4001 ,title: "PPT", text: "(会员特权)") }
    /// Excel
    internal static var excel: DDSheetItem { .init(tag: 4001 ,title: "Excel", text: "(会员特权)") }
    
}

