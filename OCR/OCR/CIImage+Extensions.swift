//
//  CIImage+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import Foundation
import CoreImage

extension CIImage {
    
    internal static func applyingFilter(image: UIImage, rectangle coordinates: (topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint)) -> UIImage {
        guard var ciImage: CIImage = .init(image: image) else { return image }
        var rectangleCoordinates: [String: Any] = [:]
        rectangleCoordinates["inputTopLeft"] = CIVector(cgPoint: coordinates.topLeft)
        rectangleCoordinates["inputTopRight"] = CIVector(cgPoint: coordinates.topRight)
        rectangleCoordinates["inputBottomLeft"] = CIVector(cgPoint: coordinates.bottomLeft)
        rectangleCoordinates["inputBottomRight"] = CIVector(cgPoint: coordinates.bottomRight)
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: rectangleCoordinates)
        return .init(ciImage: ciImage)
    }
}
