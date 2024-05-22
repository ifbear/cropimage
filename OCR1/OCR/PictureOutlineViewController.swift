//
//  PictureOutlineViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/12.
//

import UIKit
import PhotosUI
import CoreImage

class PictureOutlineViewController: UIViewController {
    private lazy var sysBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setTitle("选择图片", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var imageView: UIImageView = {
        let _imageView: UIImageView = .init()
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(sysBtn)
        sysBtn.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(32)
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(sysBtn.snp.bottom)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }


}

extension PictureOutlineViewController {
    @objc private func buttonActionHandler(_ btn: UIButton) {
        switch btn {
        case sysBtn:
            if #available(iOS 14.0, *) {
                var configuration: PHPickerConfiguration = .init(photoLibrary: .shared())
                configuration.filter = .images
                configuration.selectionLimit = 1
                let picker: PHPickerViewController = .init(configuration: configuration)
                picker.delegate = self
                present(picker, animated: true)
            } else {
                let picker: UIImagePickerController = .init(rootViewController: self)
                picker.sourceType = .photoLibrary
                picker.mediaTypes = ["public.image"]
                picker.delegate = self
                present(picker, animated: true)
            }
            
        default: break
        }
    }
    
    private func recognize() -> (URL?, Error?) -> Void {
        return { [unowned self] url, error in
            do {
                guard let url = url else { return }
                let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("temp.png")
                try? FileManager.default.removeItem(at: tempUrl)
                try FileManager.default.copyItem(at: url, to: tempUrl)
                guard let image: UIImage = .init(contentsOfFile: tempUrl.path) else { return }

                guard var ciImage: CIImage = .init(image: image) else { return }
                // 判断边缘识别度阈值, 再对拍照后的进行边缘识别
                guard let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking: true]) else { return }
                let features = detector.features(in: ciImage) as! [CIRectangleFeature]
                guard let rectangleFeature = biggestRectangleInRectangles(with: features) else { return }
                let transform = CGAffineTransform.identity
                        .scaledBy(x: 1, y: -1)
                        .translatedBy(x: 0, y: -image.size.height)
                        //.scaledBy(x: image.size.width, y: image.size.height)
                // 裁剪
                var rectangleCoordinates: [String: Any] = [:]
                rectangleCoordinates["inputTopLeft"] = CIVector(cgPoint: rectangleFeature.topLeft)
                rectangleCoordinates["inputTopRight"] = CIVector(cgPoint: rectangleFeature.topRight)
                rectangleCoordinates["inputBottomLeft"] = CIVector(cgPoint: rectangleFeature.bottomLeft)
                rectangleCoordinates["inputBottomRight"] = CIVector(cgPoint: rectangleFeature.bottomRight)
                
               ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: rectangleCoordinates)
                
                DispatchQueue.main.async {
                    self.imageView.image = image.drawBezierPath(with: [
                        rectangleFeature.topLeft.applying(transform),
                        rectangleFeature.topRight.applying(transform),
                        rectangleFeature.bottomRight.applying(transform),
                        rectangleFeature.bottomLeft.applying(transform)
                    ])
                }
                

            } catch {
                print(error)
            }
        }
    }
    
    private func biggestRectangleInRectangles(with features: [CIRectangleFeature]) -> CIRectangleFeature? {
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


extension PictureOutlineViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.isEmpty == false else { return }
        guard let result = results.first else { return }
        _ = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: recognize())
    }
}

extension PictureOutlineViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
}
