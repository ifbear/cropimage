//
//  UIImage+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/12.
//

import Foundation
import UIKit
import Vision
import Kingfisher

extension UIImage {
    
    /// crop
    /// - Parameter path: UIBezierPath
    /// - Returns: UIImage
    func crop(_ path: UIBezierPath) -> UIImage? {
        let rect = CGRect(origin: CGPoint(), size: CGSize(width: size.width * scale, height: size.height * scale))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        path.addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func drawBezierPath(with points: [CGPoint]) -> UIImage? {
        guard points.isEmpty == false else { return self }
        let rect = CGRect(origin: CGPoint(), size: CGSize(width: size.width * scale, height: size.height * scale))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        draw(in: rect)
        let path: UIBezierPath = .init()
        path.lineWidth = 2
        let first = points.first!
        path.move(to: first)
        points.dropFirst().forEach { point in
            path.addLine(to: point)
        }
//        path.addLine(to: first)
        path.close()
        let color: UIColor = .red
        color.set()
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    

}

extension UIImage: Compatible {}
extension CompatibleWrapper where Base: UIImage {
    
    /// redraw
    /// - Parameter size: CGSize
    /// - Returns: UIImage
    internal func redraw(with size: CGSize, renderingMode: UIImage.RenderingMode = .alwaysTemplate) -> UIImage {
        let size = base.size.kf.resize(to: size, for: .aspectFit)
        let render: UIGraphicsImageRenderer = .init(size: size)
        return render.image { _ in
            base.withRenderingMode(.alwaysTemplate).draw(in: .init(x: 0.0, y: 0.0, width: size.width, height: size.height))
        }.withRenderingMode(renderingMode)
    }
    
    
    /// 修复转向
    internal func fixOrientation() -> UIImage {
        if base.imageOrientation == .up { return base }
        
        var transform = CGAffineTransform.identity
        
        switch base.imageOrientation {
        case .down, .downMirrored:
            transform = CGAffineTransform(translationX: base.size.width, y: base.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = CGAffineTransform(translationX: base.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = CGAffineTransform(translationX: 0, y: base.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }
        
        switch base.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: base.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: base.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let cgImage = base.cgImage, let colorSpace = cgImage.colorSpace else { return base }
        let context = CGContext(
            data: nil,
            width: Int(base.size.width),
            height: Int(base.size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
        context?.concatenate(transform)
        switch base.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: base.size.height, height: base.size.width))
        default:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height))
        }
        
        guard let newCgImage = context?.makeImage() else { return base }
        return UIImage(cgImage: newCgImage)
    }
    
    /// crop
    /// - Parameters:
    ///   - rectangle: Rectangle
    ///   - angle: CGFloat
    /// - Returns: UIImage
    internal func crop(rectangle: Rectangle, angle: CGFloat) -> UIImage {
        guard var ciImage: CIImage = .init(image: base) else { return base }
        var rectangleCoordinates: [String: Any] = [:]
        rectangleCoordinates["inputTopLeft"] = CIVector(cgPoint: rectangle.topLeft)
        rectangleCoordinates["inputTopRight"] = CIVector(cgPoint: rectangle.topRight)
        rectangleCoordinates["inputBottomLeft"] = CIVector(cgPoint: rectangle.bottomLeft)
        rectangleCoordinates["inputBottomRight"] = CIVector(cgPoint: rectangle.bottomRight)
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: rectangleCoordinates)
        
        let newImage: UIImage = .init(ciImage: ciImage)
        // 图片大小
        let rotatedSize = CGRect(origin: .zero, size: newImage.size)
            .applying(CGAffineTransform(rotationAngle: angle))
            .size
        // 创建上下文
        let renderer = UIGraphicsImageRenderer(size: rotatedSize)
        
        let rotatedImage = renderer.image { context in
            context.cgContext.translateBy(x: rotatedSize.width * 0.5, y: rotatedSize.height * 0.5)
            context.cgContext.rotate(by: angle)
            newImage.draw(in: CGRect(x: -newImage.size.width * 0.5, y: -newImage.size.height * 0.5, width: newImage.size.width, height: newImage.size.height))
        }
        return rotatedImage
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }

        return nil
    }
}
