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
struct Rectangle {
    internal var topLeft: CGPoint
    internal var topRight: CGPoint
    internal var bottomLeft: CGPoint
    internal var bottomRight: CGPoint
    
    internal static var `default`: Rectangle = .init(topLeft: .zero, topRight: .zero, bottomLeft: .zero, bottomRight: .zero)
    
    /// 转换坐标
    /// - Parameters:
    ///   - topLeft: CGPoint
    ///   - topRight: CGPoint
    ///   - bottomLeft: CGPoint
    ///   - bottomRight: CGPoint
    ///   - view: UIImageView
    internal static func convert(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint, for imageView: UIImageView) -> Rectangle {
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
    
    /// UIKIt坐标与CoreImage 坐标互相转换
    /// - Parameter imageSize: CGSize
    /// - Returns: Position
    internal func convertRectangle(with size: CGSize, scale: CGFloat) -> Rectangle {
        let tl = topLeft.convert(for: size, scaleBy: scale)
        let tr = topRight.convert(for: size, scaleBy: scale)
        let bl = bottomLeft.convert(for: size, scaleBy: scale)
        let br = bottomRight.convert(for: size, scaleBy: scale)
        return .init(topLeft: tl, topRight: tr, bottomLeft: bl, bottomRight: br)
    }
    
    /// UIKIt坐标与CoreImage 坐标互相转换
    /// - Parameter imageSize: CGSize
    /// - Returns: Position
    internal func convert(with scale: CGFloat) -> Rectangle {
        let tl = topLeft.convert(scaleBy: scale)
        let tr = topRight.convert(scaleBy: scale)
        let bl = bottomLeft.convert(scaleBy: scale)
        let br = bottomRight.convert(scaleBy: scale)
        return .init(topLeft: tl, topRight: tr, bottomLeft: bl, bottomRight: br)
    }
    
    /// checkValid
    /// - Returns: Bool
    func checkValid() -> Bool {
        // 获取四个顶点
        let point1 = topLeft
        let point2 = topRight
        let point3 = bottomRight
        let point4 = bottomLeft

        // 计算任意两个相邻边的向量
        let vector1 = CGVector(dx: point2.x - point1.x, dy: point2.y - point1.y)
        let vector2 = CGVector(dx: point3.x - point2.x, dy: point3.y - point2.y)
        let vector3 = CGVector(dx: point4.x - point3.x, dy: point4.y - point3.y)
        let vector4 = CGVector(dx: point1.x - point4.x, dy: point1.y - point4.y)

        // 计算叉积
        let crossProduct1 = vector1.dx * vector2.dy - vector1.dy * vector2.dx
        let crossProduct2 = vector2.dx * vector3.dy - vector2.dy * vector3.dx
        let crossProduct3 = vector3.dx * vector4.dy - vector3.dy * vector4.dx
        let crossProduct4 = vector4.dx * vector1.dy - vector4.dy * vector1.dx

        // 检查叉积的方向
        let anglesLessThan180 = (crossProduct1 > 0 && crossProduct2 > 0 && crossProduct3 > 0 && crossProduct4 > 0) ||
                                 (crossProduct1 < 0 && crossProduct2 < 0 && crossProduct3 < 0 && crossProduct4 < 0)

        return anglesLessThan180
    }
}

class DDCropModel {
    
    /// uniqueID
    internal let uniqueID: String
    
    /// 原始图片
    internal var image: UIImage
    
    /// 裁剪图片
    internal var cropImage: UIImage?
    
    /// 旋转角度
    internal var originAngle: OriginAngle = .deg0
    
    /// 裁剪边框位置
    internal var rectangle: Rectangle = .default

    internal init(image: UIImage, cropImage: UIImage? = nil, originAngle: OriginAngle = .deg0, cropPosition: Rectangle = .default) {
        self.uniqueID = UUID().uuidString
        self.image = image
        self.cropImage = cropImage
        self.originAngle = originAngle
        self.rectangle = cropPosition
    }
}

extension DDCropModel: Hashable {
    /// hash
    /// - Parameter hasher: Hasher
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueID)
    }
    
    /// ==
    /// - Parameters:
    ///   - lhs: DDCropModel
    ///   - rhs: DDCropModel
    /// - Returns: Bool
    internal static func == (lhs: DDCropModel, rhs: DDCropModel) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
    
    /// originalSize
    internal var originalSize: CGSize {
        image.size
    }
}
