
//
//  UIWindow+Extends.swift.swift
//  SinaMail
//
//  Created by tramp on 2021/11/24.
//

import Foundation
import UIKit


extension UIView: Compatible {}

extension UIWindow {
    
    /// 标签
    internal struct Tag: Hashable {
        internal let rawValue: Int
        /// 构建
        internal init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension UIWindow.Tag {
    /// 未知窗口
    internal static var none: UIWindow.Tag { .init(rawValue: 0) }
    /// 默认窗口
    internal static var `default`: UIWindow.Tag { .init(rawValue: 1 << 1) }
    /// 重新授权窗口
    internal static var reAuth: UIWindow.Tag { .init(rawValue: 1 << 2) }
    // 授权窗口
    internal static var warrant: UIWindow.Tag { .init(rawValue: 1 << 3) }
    /// 安全锁
    internal static var safelock: UIWindow.Tag { .init(rawValue: 1 << 4) }
    /// 广告窗口
    internal static var ads: UIWindow.Tag { .init(rawValue: 1 << 5) }
    /// 交易窗口
    internal static var trade: UIWindow.Tag { .init(rawValue: 1 << 6) }
    /// 广告授权窗口
    internal static var adAccess: UIWindow.Tag { .init(rawValue: 1 << 7) }
}

extension UIWindow {
    
    /// 构建
    /// - Parameters:
    ///   - tag: Tag
    ///   - frame: CGRect
    internal convenience init(tag: Tag, frame: CGRect) {
        self.init(frame: frame)
        self.hub.tag = tag
    }
    
    /// 构建
    /// - Parameters:
    ///   - tag: 标签
    ///   - windowScene: UIWindowScene
    internal convenience init(tag: Tag, windowScene: UIWindowScene) {
        self.init(windowScene: windowScene)
        self.hub.tag = tag
    }
}

extension CompatibleWrapper where Base: UIWindow {
    
    /// 窗口标签
    internal var tag: UIWindow.Tag {
        get { .init(rawValue: base.tag) }
        set { base.tag = newValue.rawValue }
    }
    
    /// 获取顶部控制器
    internal var summitViewController: UIViewController? {
        guard let controller = base.rootViewController else { return nil }
        return UIApplication.shared.hub.findTop(of: controller)
    }
    
}

extension UIWindow.Level {
    
    /// 授权窗口
    internal static var warrant: UIWindow.Level {
        return .init(rawValue: alert.rawValue + 10.0)
    }
    
    /// 安全锁
    internal static var safelock: UIWindow.Level {
        return .init(rawValue: alert.rawValue + 20.0)
    }
    
    /// 广告
    internal static var ads: UIWindow.Level {
        return .init(rawValue: alert.rawValue + 30.0)
    }
    
    /// 交易窗口
    internal static var trade: UIWindow.Level {
        return .init(rawValue: ads.rawValue + 1.0)
    }
    
    /// 广告授权
    internal static var adAccess: UIWindow.Level {
        return .init(rawValue: ads.rawValue + 2.0)
    }
}

extension UIWindow.Level: CompatibleValue {}
extension CompatibleWrapper where Base == UIWindow.Level {
    
    /// offset by value
    /// - Parameter value: CGFloat
    /// - Returns: UIWindow.Level
    internal func offset(by value: CGFloat) -> UIWindow.Level {
        return .init(rawValue: base.rawValue + value)
    }
}
