//
//  UIFont+Extends.swift
//  SinaMail
//
//  Created by tramp on 2021/11/25.
//

import Foundation
import UIKit

extension UIFont {
    /// 苹方简体
    internal enum PingFangSC: String {
        /// PingFangSC-Regular
        case regular = "PingFangSC-Regular"
        /// PingFangSC-Ultralight
        case utralight = "PingFangSC-Ultralight"
        /// PingFangSC-Thin
        case thin = "PingFangSC-Thin"
        /// PingFangSC-Light
        case light = "PingFangSC-Light"
        /// PingFangSC-Medium
        case medium = "PingFangSC-Medium"
        /// PingFangSC-Semibold
        case semibold = "PingFangSC-Semibold"
        
        /// UIFont.Weight
        internal var weight: UIFont.Weight {
            switch self {
            case .regular:      return .regular
            case .utralight:    return .ultraLight
            case .thin:         return .thin
            case .light:        return .light
            case .medium:       return .medium
            case .semibold:     return .semibold
            }
        }
    }
}

extension UIFont {

    /// 获取苹方简体
    /// - Parameters:
    ///   - size: CGFloat
    ///   - style: PingFangSC
    /// - Returns: UIFont
    internal static func pingfang(ofSize size: CGFloat, weight: PingFangSC = .regular) -> UIFont {
        if let font: UIFont = .init(name: weight.rawValue, size: size) {
            return font
        } else {
            return .systemFont(ofSize: size, weight: weight.weight)
        }
    }
    
}

@available(iOS 15, *)
extension AttributeScopes.UIKitAttributes.FontAttribute {
    /// UIFont.PingFangSC
    internal typealias PingFangSC = UIFont.PingFangSC
    
    /// 获取苹方简体
    /// - Parameters:
    ///   - size: CGFloat
    ///   - style: PingFangSC
    /// - Returns: UIFont
    internal static func pingfang(ofSize size: CGFloat, weight: PingFangSC = .regular) -> UIFont {
        if let font: UIFont = .init(name: weight.rawValue, size: size) {
            return font
        } else {
            return .systemFont(ofSize: size, weight: weight.weight)
        }
    }
}

extension UIFont: Compatible {}
extension CompatibleWrapper where Base: UIFont {
    
    /// with name
    /// - Parameter name: String
    /// - Returns: UIFont
    internal func with(name: String) -> UIFont {
        return UIFont.init(name: name, size: base.pointSize) ?? base
    }
    
    /// apply newTraits
    /// - Parameters:
    ///   - newTraits: UIFontDescriptor.SymbolicTraits
    ///   - newPointSize: CGFloat
    /// - Returns: UIFont
    internal func apply(newTraits: UIFontDescriptor.SymbolicTraits, newPointSize: CGFloat? = nil) -> UIFont {
        var existingTraits = base.fontDescriptor.symbolicTraits
        existingTraits.insert(newTraits)
        if let descriptor = base.fontDescriptor.withSymbolicTraits(existingTraits) {
            return .init(descriptor: descriptor, size: newPointSize ?? base.pointSize)
        } else {
            return base
        }
    }
    
    /// monospaced
    /// - Parameter weight: UIFont.Weight
    /// - Returns: UIFont
    internal func monospaced(_ weight: UIFont.Weight = .regular) -> UIFont {
        return .monospacedSystemFont(ofSize: base.pointSize, weight: weight)
    }
    
    /// Bool
    internal var isTraitBold: Bool {
        return base.fontDescriptor.symbolicTraits.intersection(.traitBold) == .traitBold
    }
    
}
