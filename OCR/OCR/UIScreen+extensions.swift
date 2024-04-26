//
//  UIScreen+extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/26.
//

import Foundation
import UIKit

extension UIScreen {
    
    /// UIScreen
    internal static var current: UIScreen {
        if Thread.isMainThread == true {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.hub.keyWindow?.windowScene?.screen ?? .main
            } else {
                return .main
            }
        } else {
            return DispatchQueue.main.sync { UIScreen.current }
        }
    }
    
}


extension UIScreen: Compatible {}
extension CompatibleWrapper where Base: UIScreen {
    

    /// CGFloat
    internal var miniWidth: CGFloat {
        return min(base.bounds.width, base.bounds.height)
    }
}

