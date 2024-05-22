//
//  UIImageView+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/18.
//

import Foundation
import UIKit

extension UIImageView {
    internal var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scaleWidth = frame.width / image.size.width
        let scaleHeight = frame.height / image.size.height
        let aspect = fmin(scaleWidth, scaleHeight)

        var imageRect = CGRect(x: 0, y: 0, width: image.size.width * aspect, height: image.size.height * aspect)
        // Center image
        imageRect.origin.x = (frame.width - imageRect.size.width) / 2
        imageRect.origin.y = (frame.height - imageRect.size.height) / 2

        // Add imageView offset
        imageRect.origin.x += frame.origin.x
        imageRect.origin.y += frame.origin.y

        return imageRect
    }
    
}
