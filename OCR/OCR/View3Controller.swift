//
//  View3Controller.swift
//  OCR
//
//  Created by dexiong on 2024/4/10.
//

import UIKit

import PhotosUI
import Vision

import Foundation
import CoreGraphics


class View3Controller: UIViewController {
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
extension View3Controller {
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
                let request = VNRecognizeTextRequest {  request, error in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                    DispatchQueue.main.async {
                        
                        let transform = CGAffineTransform.identity
                                .scaledBy(x: 1, y: -1)
                                .translatedBy(x: 0, y: -image.size.height)
                                .scaledBy(x: image.size.width, y: image.size.height)

//                        var rectangles: [Rectangle] = []
                        var points: [CGPoint] = []
                        for observation in observations {
                            if let text = observation.topCandidates(1).first,
                               let range: Range<String.Index> = text.string.range(of: text.string),
                               let box = try? text.boundingBox(for: range) {
                                points.append(box.topLeft)
                                points.append(box.topRight)
                                points.append(box.bottomRight)
                                points.append(box.bottomLeft)
//                                rectangles.append(.init(topLeft: box.topLeft.applying(transform), topRight: box.topRight.applying(transform), bottomLeft: box.bottomLeft.applying(transform), bottomRight: box.bottomRight.applying(transform)))
                            }
                        }
                        let p = self.rotatingCalipers(points: points).map {$0.applying(transform)}
                        self.imageView.image = image.drawBezierPath(with: p)
                    }
                }
                request.progressHandler = { _, progress, _ in
                    print(progress)
                }
                request.recognitionLevel = .accurate
                if #available(iOS 16.0, *) {
                    request.automaticallyDetectsLanguage = true
                }
                guard let cgImage = UIImage(contentsOfFile: url.path)?.cgImage else { return }
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                DispatchQueue.global().async {
                    try? handler.perform([request])
                }

            } catch {
                print(error)
            }
        }
    }
    
    

    // 计算两点之间的距离的平方
    func squaredDistance(_ p1: CGPoint, _ p2: CGPoint) -> Double {
        return pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2)
    }

    // 计算叉积
    func crossProduct(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> Double {
        return (p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y)
    }

    // 计算凸包
    func convexHull(_ points: [CGPoint]) -> [CGPoint] {
        guard points.count >= 3 else { return [] }
        
        let sortedPoints = points.sorted(by: {
            if $0.x != $1.x {
                return $0.x < $1.x
            } else {
                return $0.y < $1.y
            }
        })
        
        var stack = [CGPoint]()
        
        for p in sortedPoints {
            while stack.count >= 2 && crossProduct(stack[stack.count - 2], stack[stack.count - 1], p) <= 0 {
                stack.removeLast()
            }
            stack.append(p)
        }
        
        let upperHull = stack
        
        stack.removeAll()
        
        for p in sortedPoints.reversed() {
            while stack.count >= 2 && crossProduct(stack[stack.count - 2], stack[stack.count - 1], p) <= 0 {
                stack.removeLast()
            }
            stack.append(p)
        }
        
        let lowerHull = stack
        
        if upperHull.count == 1 && lowerHull.count == 1 {
            return stack
        }
        
        return Array(upperHull.dropLast() + lowerHull.dropLast())
    }

    // 计算最小外接矩形的顶点
    func minimumBoundingRectangleVertices(_ points: [CGPoint]) -> [CGPoint]? {
        let hull = convexHull(points)
        
        
        
        
        
        
        
        let wrapper = OpenCVWrapper()
        let values = wrapper.minimumBoundingRectangleVertices(points.map { NSValue(cgPoint: $0) })
        return values.map { $0.cgPointValue }
    }

    func rotatingCalipers(points: [CGPoint]) -> [CGPoint] {
        // 计算凸包
        let convexHull = convexHull( points)
        
        // 初始化旋转卡廷
        var i = 0
        var j = 1
        var minArea = Double.infinity
        var minRectangle: [CGPoint] = []
        
        // 旋转卡廷
        while true {
            let vectorI = vector(from: convexHull[i], to: convexHull[j])
            
            var width = distanceBetweenPoints(point1: convexHull[i], point2: convexHull[j])
            var height = 0.0
            
            // 找到下一个点构成的边
            var next = (j + 1) % convexHull.count
            var iterations = 0
            
            while true {
                let vectorJ = vector(from: convexHull[j], to: convexHull[next])
                let crossProduct = vectorI.x * vectorJ.y - vectorI.y * vectorJ.x
                
                if crossProduct <= 0 {
                    width += distanceBetweenPoints(point1: convexHull[j], point2: convexHull[next])
                    j = next
                    next = (next + 1) % convexHull.count
                } else {
                    height = distanceBetweenPoints(point1: convexHull[i], point2: convexHull[j])
                    break
                }
                
                iterations += 1
                if iterations > convexHull.count {
                    break
                }
            }
            
            let area = width * height
            if area < minArea {
                minArea = area
                minRectangle = [
                    convexHull[i],
                    convexHull[j],
                    convexHull[(j + 1) % convexHull.count],
                    convexHull[(i + 1) % convexHull.count]
                ]
            }
            
            i = (i + 1) % convexHull.count
            if i == 0 {
                break
            }
        }
        
        return minRectangle
    }

    func vector(from point1: CGPoint, to point2: CGPoint) -> CGPoint {
        return CGPoint(x: point2.x - point1.x, y: point2.y - point1.y)
    }

    func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> Double {
        return sqrt((point2.x - point1.x) * (point2.x - point1.x) + (point2.y - point1.y) * (point2.y - point1.y))
    }
    
}


extension View3Controller: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.isEmpty == false else { return }
        guard let result = results.first else { return }
        _ = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: recognize())
    }
}

extension View3Controller: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
}
