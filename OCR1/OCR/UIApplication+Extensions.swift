//
//  UIApplication+Extends.swift
//  SinaMail
//
//  Created by tramp on 2021/11/24.
//

import Foundation
import UIKit
import CoreData
import QuickLook

extension UIApplication: Compatible {}
extension CompatibleWrapper where Base: UIApplication {

    
    /// The app's key window.
    internal var keyWindow: UIWindow? {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.keyWindow }
        }
        if #available(iOS 15.0, *) {
            let connectedScenes: [UIWindowScene] = base.connectedScenes.compactMap { $0 as? UIWindowScene }
            for connectedScene in connectedScenes {
                guard let window = connectedScene.windows.first(where: \.isKeyWindow) else { continue }
                return window
            }
            return UIApplication.shared.hub.window(for: .default)
        } else {
            return base.windows.first(where: \.isKeyWindow) ?? UIApplication.shared.hub.window(for: .default)
        }
    }
    
    /// UIScreen
    internal var screen: UIScreen? {
        if Thread.isMainThread == true {
            return base.hub.keyWindow?.screen
        } else {
            return DispatchQueue.main.sync { base.hub.keyWindow?.screen }
        }
    }
    
    /// The app's top viewController.
    internal func summitViewController(of window: UIWindow) -> UIViewController? {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync(execute: { self.summitViewController(of: window) })
        }
        guard let controller = window.rootViewController else { return nil }
        return findTop(of: controller)
    }
    
    /// The app's top viewController.
    internal var summitViewController: UIViewController? {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.summitViewController }
        }
        guard let controller = keyWindow?.rootViewController else { return nil }
        return findTop(of: controller)
    }
    
    /// The insets that you use to determine the safe area for this view.
    internal var safeAreaInsets: UIEdgeInsets {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.safeAreaInsets }
        }
        return keyWindow?.safeAreaInsets ?? .zero
    }
    
    /// The frame rectangle defining the area of the status bar.
    internal var statusBarFrame: CGRect {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.statusBarFrame }
        }
        let connectedScenes: [UIWindowScene] = base.connectedScenes.compactMap { $0 as? UIWindowScene }
        return connectedScenes.first(where: { $0.statusBarManager != nil })?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    /// 是否是刘海屏幕
    internal var isNotch: Bool {
        return UIApplication.shared.hub.safeAreaInsets.bottom > 0.0 && UIDevice.current.userInterfaceIdiom != .pad
    }
    
    /// UIInterfaceOrientation
    internal var interfaceOrientation: UIInterfaceOrientation {
        return base.hub.keyWindow?.windowScene?.interfaceOrientation ?? .portrait
    }
}

extension CompatibleWrapper where Base: UIApplication {
    
    /// 获取标签窗口
    /// - Parameter tag: UIWindow.Tag
    /// - Returns: UIWindow
    internal func window(for tag: UIWindow.Tag) -> UIWindow? {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.window(for: tag) }
        }
        if #available(iOS 15.0, *) {
            let connectedScenes: [UIWindowScene] = base.connectedScenes.compactMap { $0 as? UIWindowScene }
            for connectedScene in connectedScenes {
                guard let window = connectedScene.windows.first(where: { $0.hub.tag == tag }) else { continue }
                return window
            }
            return nil
        } else {
            return base.windows.first(where: { $0.hub.tag == tag })
        }
    }
    
    /// find top controller
    /// - Parameter target: UIViewController
    /// - Returns: UIViewController
    internal func findTop(of target: UIViewController) -> UIViewController {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.findTop(of: target) }
        }
        if let target = target as? UINavigationController, let topViewController = target.visibleViewController {
            return findTop(of: topViewController)
        } else if let target = target as? UITabBarController, let selectedViewController = target.selectedViewController {
            return findTop(of: selectedViewController)
        } else if let target = target as? UISplitViewController, let controller = target.viewControllers.last {
            return findTop(of: controller)
        } else if let presentedViewController = target.presentedViewController {
            return findTop(of: presentedViewController)
        } else {
            return target
        }
    }
    
    /// containsAnyClass
    /// - Parameter cls: AnyClass
    /// - Returns: Bool
    internal func contains(kindOf cls: AnyClass) -> Bool {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.contains(kindOf: cls) }
        }
        return contains(of: keyWindow?.rootViewController, kindOf: cls)
    }
    
    /// find top controller
    /// - Parameter target: UIViewController
    /// - Returns: UIViewController
    internal func contains(of target: UIViewController?, kindOf cls: AnyClass) -> Bool {
        guard Thread.isMainThread == true else {
            return DispatchQueue.main.sync { self.contains(of: target, kindOf: cls) }
        }
        guard let target = target else { return false }
        if target.isKind(of: cls) == true {
            return true
        } else if let target = target as? UINavigationController {
            if target.viewControllers.contains(where: { $0.isKind(of: cls) == true }) == true {
                return true
            } else {
                return contains(of: target.presentedViewController, kindOf: cls)
            }
        } else if let target = target as? UITabBarController {
            if target.viewControllers?.contains(where: { $0.isKind(of: cls) == true }) == true {
                return true
            } else {
                return contains(of: target.presentedViewController, kindOf: cls)
            }
        } else if let target = target as? UISplitViewController {
            if target.viewControllers.contains(where: { $0.isKind(of: cls) == true }) == true {
                return true
            } else {
                return contains(of: target.presentedViewController, kindOf: cls)
            }
        } else if let presentedViewController = target.presentedViewController {
            return contains(of: presentedViewController, kindOf: cls)
        } else {
            return target.isKind(of: cls)
        }
    }
    
}
