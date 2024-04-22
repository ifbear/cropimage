//
//  ScanningModels.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import Foundation
import UIKit


/// 旋转基准角度：0°/360°、90°、180°、270°
enum OriginAngle: CGFloat {
    /// 以 0°/360° 为基准，可旋转范围：`-45° ~ 45°`
    case deg0 = 0
    
    /// 以 90° 为基准，可旋转范围：`45° ~ 135°`
    case deg90 = 90
    
    /// 以 180° 为基准，可旋转范围：`135° ~ 225°`
    case deg180 = 180
    
    /// 以 270° 为基准，可旋转范围：`225° ~ 315°`
    case deg270 = 270
    
    /// 上一个基准角度
    internal var prev: Self {
        switch self {
        case .deg0: return .deg270
        case .deg90: return .deg0
        case .deg180: return .deg90
        case .deg270: return .deg180
        }
    }
    
    /// 下一个基准角度
    internal var next: Self {
        switch self {
        case .deg0: return .deg90
        case .deg90: return .deg180
        case .deg180: return .deg270
        case .deg270: return .deg0
        }
    }
    
    /// 顺时针旋转角度
    internal var clockwiseRotationAngle: CGFloat {
        switch self {
        case .deg0:     return CGFloat.pi * 0
        case .deg90:    return CGFloat.pi * 0.5
        case .deg180:   return CGFloat.pi * 1.0
        case .deg270:   return CGFloat.pi * 1.5
        }
    }
    
    /// 逆时针旋转角度
    internal var counterclockwiseRotationAngle: CGFloat {
        return -clockwiseRotationAngle
    }
}


/// 调整边框坐标
struct Position {
    internal var topLeft: CGPoint
    internal var topRight: CGPoint
    internal var bottomLeft: CGPoint
    internal var bottomRight: CGPoint
    
    internal static var `default`: Position = .init(topLeft: .zero, topRight: .zero, bottomLeft: .zero, bottomRight: .zero)
    
    /// 转换坐标
    /// - Parameters:
    ///   - topLeft: <#topLeft description#>
    ///   - topRight: <#topRight description#>
    ///   - bottomLeft: <#bottomLeft description#>
    ///   - bottomRight: <#bottomRight description#>
    ///   - view: <#view description#>
    internal static func convert(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint, for imageView: UIImageView) -> Position {
        guard let image = imageView.image else { return .default }
        let rect = imageView.contentClippingRect
        let scaleFactor = rect.height / image.size.height
        let transform = CGAffineTransform.identity
            .scaledBy(x: scaleFactor, y: -scaleFactor)
            .translatedBy(x: 0, y: -image.size.height)
        let _tl = topLeft.applying(transform)
        let _tr = topRight.applying(transform)
        let _bl = bottomLeft.applying(transform)
        let _br = bottomRight.applying(transform)
        
        return .init(topLeft: _tl, topRight:_tr, bottomLeft: _bl, bottomRight: _br)
    }
    
}

struct ScanningCropModel {
    
    /// 原始图片
    internal var originalImage: UIImage
    
    /// 原始旋转角度
    internal var originalAngle: OriginAngle = .deg0
    
    /// 原始边框位置
    internal var originalPosition: Position = .default
    
    /// 裁剪图片
    internal var cropImage: UIImage?
    
    /// 旋转角度
    internal var cropAngle: OriginAngle = .deg0
    
    /// 裁剪边框位置
    internal var cropPosition: Position = .default

    
}

extension ScanningCropModel {
    
    /// originalSize
    internal var originalSize: CGSize {
        originalImage.size
    }
}
