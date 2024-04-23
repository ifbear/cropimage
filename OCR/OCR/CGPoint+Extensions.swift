//
//  CGPoint+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import Foundation

extension CGPoint {
    
    /// distance
    /// - Parameter point: CGPoint
    /// - Returns: CGFloat
    internal func distance(_ point: CGPoint) -> CGFloat {
        let x: CGFloat = x - point.x
        let y: CGFloat = y - point.y
        return sqrt(x * x + y * y)
    }

    
    /// convert
    /// - Parameters:
    ///   - size: CGSize
    ///   - scale: CGFloat
    /// - Returns: CGPoint
    internal func convert(for size: CGSize, scaleBy scale: CGFloat) -> CGPoint {
        // 根据缩放比例对 CGPoint 进行调整
        let scaledPoint = CGPoint(x: x * scale, y: y * scale)
        // Core Image 坐标系原点在左下角，因此需要对 y 值进行翻转
        let flippedY = size.height - scaledPoint.y
        return CGPoint(x: scaledPoint.x, y: flippedY)
    }
}
