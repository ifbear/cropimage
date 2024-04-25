//
//  WeakProxy.swift
//  OCR
//
//  Created by dexiong on 2024/4/25.
//

import Foundation

class WeakProxy: NSObject {
    private weak var target: NSObjectProtocol?
    
    init(_ target: NSObjectProtocol) {
        self.target = target
        super.init()
    }
    
    class func proxy(target: NSObjectProtocol) -> WeakProxy {
        return WeakProxy(target)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return target?.responds(to: aSelector) ?? false
    }
}
