//
//  View1Controller.swift
//  OCR
//
//  Created by dexiong on 2024/4/1.
//

import UIKit
import PhotosUI
import Vision

import Foundation
import CoreGraphics

class View1Controller: UIViewController {
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
extension View1Controller {
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
                        var points: [Rectangle] = []
//                        var points: [Point] = []
                        for observation in observations {
                            if let text = observation.topCandidates(1).first,
                               let range: Range<String.Index> = text.string.range(of: text.string),
                                let box = try? text.boundingBox(for: range) {
                                points.append(.init(topLeft: .init(x: box.topLeft.x, y: box.topLeft.y), topRight: .init(x: box.topRight.x, y: box.topRight.y), bottomLeft: .init(x: box.bottomLeft.x, y: box.bottomLeft.y), bottomRight: .init(x: box.bottomRight.x, y: box.bottomRight.y)))
//                                points.append(.init(topLeft: box.topLeft.point, bottomRight: box.bottomRight.point))
//                                points.append(.init(x: box.topLeft.x, y: box.topLeft.y))
//                                points.append(.init(x: box.topRight.x, y: box.topRight.y))
//                                points.append(.init(x: box.bottomRight.x, y: box.bottomRight.y))
//                                points.append(.init(x: box.bottomLeft.x, y: box.bottomLeft.y))
                            }
                        }
                        
                        let position = self.findMinimumTrapezoid(rectangles: points)
                        let transform = CGAffineTransform.identity
                                .scaledBy(x: 1, y: -1)
                                .translatedBy(x: 0, y: -image.size.height)
                                .scaledBy(x: image.size.width, y: image.size.height)
                        let _points = position.map(\.point).map({ point in
                            return point.applying(transform)
                        })
                        self.imageView.image = image.drawBezierPath(with: _points)
//                        var topLeft: CGPoint = .init(x: 1.0, y: 0)
//                        var topRight: CGPoint = .init(x: 0.0, y: 0.0)
//                        var bottomRight: CGPoint = .init(x: 0.0, y: 1.0)
//                        var bottomLeft: CGPoint = .init(x: 1.0, y: 1.0)
//                        for observation in observations {
//                            if let text = observation.topCandidates(1).first,
//                               let range: Range<String.Index> = text.string.range(of: text.string),
//                                let box = try? text.boundingBox(for: range) {
//                                print(box.topLeft, text.string)
//                                topLeft = CGPoint(x: min(box.topLeft.x, topLeft.x), y: max(box.topLeft.y, topLeft.y))
//                                topRight = CGPoint(x: max(box.topRight.x, topRight.x), y: max(box.topRight.y, topRight.y))
//                                bottomRight = CGPoint(x: max(box.bottomRight.x, bottomRight.x), y: min(box.bottomRight.y, bottomRight.y))
//                                bottomLeft = CGPoint(x: min(box.bottomLeft.x, bottomLeft.x), y: min(box.bottomLeft.y, bottomLeft.y))
//                            }
//                        }
                        
//                        let transform = CGAffineTransform.identity
//                                .scaledBy(x: 1, y: -1)
//                                .translatedBy(x: 0, y: -image.size.height)
//                                .scaledBy(x: image.size.width, y: image.size.height)
//                        let points = [topLeft, topRight, bottomRight, bottomLeft].map({ point in
//                            return point.applying(transform)
//                        })
//                        self.imageView.image = image.drawBezierPath(with: points)

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


    // 定义点结构体
    struct Point: Hashable {
        var x: CGFloat
        var y: CGFloat
        
        var point: CGPoint {
            return .init(x: x, y: y)
        }
    }

    // 定义矩形结构体
    struct Rectangle {
        var topLeft: Point
        var topRight: Point
        var bottomLeft: Point
        var bottomRight: Point
    }

    // 找到包含所有矩形的最小梯形
    func findMinimumTrapezoid(rectangles: [Rectangle]) -> [Point] {
        var points = Set<Point>()
        for rect in rectangles {
            points.insert(rect.topLeft)
            points.insert(rect.topRight)
            points.insert(rect.bottomLeft)
            points.insert(rect.bottomRight)
        }
        
        // 找到点集的凸包
        let convexHull = calculateConvexHull(Array(points))
        return convexHull
    }

    // 计算点集的凸包
    func calculateConvexHull(_ points: [Point]) -> [Point] {
        // 如果点集少于 3 个，直接返回
        if points.count < 3 {
            return points
        }
        
        // 对点集按照 x 坐标进行排序
        let sortedPoints = points.sorted { $0.x < $1.x }
        
        // 定义上半部分和下半部分的凸包
        var upperHull = [Point]()
        var lowerHull = [Point]()
        
        // 遍历所有点，构建上半部分和下半部分的凸包
        for point in sortedPoints {
            while upperHull.count >= 2 && orientation(upperHull[upperHull.count - 2], upperHull[upperHull.count - 1], point) <= 0 {
                upperHull.removeLast()
            }
            upperHull.append(point)
            
            while lowerHull.count >= 2 && orientation(lowerHull[lowerHull.count - 2], lowerHull[lowerHull.count - 1], point) >= 0 {
                lowerHull.removeLast()
            }
            lowerHull.append(point)
        }
        
        // 合并上半部分和下半部分的凸包
        return upperHull + lowerHull.dropFirst().dropLast().reversed()
    }

    // 计算点的方向
    func orientation(_ p: Point, _ q: Point, _ r: Point) -> CGFloat {
        let value = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
        if value == 0 {
            return 0
        }
        return value > 0 ? 1 : -1
    }
    

}

fileprivate extension CGPoint {
    var point: View1Controller.Point {
        return .init(x: x, y: y)
    }
}


extension View1Controller: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.isEmpty == false else { return }
        guard let result = results.first else { return }
        _ = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: recognize())
    }
}

extension View1Controller: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
}
