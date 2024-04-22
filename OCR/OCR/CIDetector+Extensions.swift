//
//  CIDetector+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import Foundation

extension CIDetector {
 
    
    /// rectangle
    /// - Parameter image: UIImage
    /// - Returns: CIRectangleFeature?
    internal static func rectangle(with image: UIImage) -> CIRectangleFeature? {
        guard let ciImage: CIImage = .init(image: image),
              let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking: true])
        else { return nil }
        
        // 判断边缘识别度阈值, 再对拍照后的进行边缘识别
        let features = detector.features(in: ciImage) as! [CIRectangleFeature]
        return biggestRectangleInRectangles(with: features)
    }
    
    private static func biggestRectangleInRectangles(with features: [CIRectangleFeature]) -> CIRectangleFeature? {
        guard features.isEmpty == false else { return nil }
        var halfPerimiterValue: Float = 0.0
        
        var biggestRectangle = features.first
        for feature in features {
            let p1 = feature.topLeft
            let p2 = feature.topRight
            let width = hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
            let p3 = feature.bottomLeft
            let p4 = feature.bottomRight
            let height = hypotf(Float(p3.x - p4.x), Float(p3.y - p4.y))
            let currentHalfPerimiterValue = height + width
            if halfPerimiterValue < currentHalfPerimiterValue {
                halfPerimiterValue = currentHalfPerimiterValue
                biggestRectangle = feature
            }
        }
        return biggestRectangle
    }
}
