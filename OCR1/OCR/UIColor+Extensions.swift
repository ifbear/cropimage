//
//  UIColor+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/25.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String) {
        // 去除字符串中的 # 符号
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        // 将字符串转换为整数
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        // 提取颜色的红、绿、蓝分量
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        // 创建 UIColor 对象
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
