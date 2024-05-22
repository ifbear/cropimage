//
//  CIImage+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import Foundation
import AVFoundation
import CoreImage


extension AVCaptureConnection: Compatible {}
extension CompatibleWrapper where Base: AVCaptureConnection {
    
    /**
     switch orientation {
     // Home button on top
     case UIDeviceOrientation.portraitUpsideDown: .videoRotationAngle = 270
     // Home button on right
     case UIDeviceOrientation.landscapeLeft: .videoRotationAngle = 0
     // Home button on left
     case UIDeviceOrientation.landscapeRight: .videoRotationAngle = 180
     // Home button at bottom
     case UIDeviceOrientation.portrait: .videoRotationAngle = 90
     default:videoRotationAngle = 90
     */
    /// videoOrientation
    internal var videoOrientation: AVCaptureVideoOrientation {
        get {
            if #available(iOS 17.0, *) {
                switch base.videoRotationAngle {
                case 0:     return .landscapeLeft
                case 90:    return .portrait
                case 180:   return .landscapeRight
                case 270:   return .portraitUpsideDown
                default:    return .portrait
                }
            } else {
                return base.videoOrientation
            }
        }
        set {
            if #available(iOS 17.0, *) {
                switch newValue {
                case .portrait:             base.videoRotationAngle = 90
                case .landscapeLeft:        base.videoRotationAngle = 0
                case .landscapeRight:       base.videoRotationAngle = 180
                case .portraitUpsideDown:   base.videoRotationAngle = 270
                @unknown default:           base.videoRotationAngle = 90
                }
            } else {
                base.videoOrientation = newValue
            }
        }
    }
    
    /// isVideoOrientationSupported
    internal var isVideoOrientationSupported: Bool {
        if #available(iOS 17.0, *) {
            return base.isVideoRotationAngleSupported(0) && base.isVideoRotationAngleSupported(90) && base.isVideoRotationAngleSupported(270) && base.isVideoRotationAngleSupported(180)
        } else {
            return base.isVideoOrientationSupported
        }
    }
}

