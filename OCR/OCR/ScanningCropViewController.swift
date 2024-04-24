//
//  ScanningCropViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/16.
//

import UIKit
import CoreGraphics

class ScanningCropViewController: UIViewController {
    
    /// 重拍回调
    internal var retakeActionHandler: (() -> Void)? = nil
    
    /// 编辑完成回调
    internal var reloadActionHandler: (() -> Void)? = nil
    
    /// scanningCropView
    private lazy var scanningCropView: ScanningCropView = {
        let _view: ScanningCropView = .init(frame: view.bounds, image: image)
        _view.delegate = self
        return _view
    }()
    
    /// UILabel
    private lazy var titleView: UILabel = {
        let _label: UILabel = .init()
        _label.text = "拖动圆点调整边缘"
        _label.font = .systemFont(ofSize: 17.0)
        _label.textColor = .white
        return _label
    }()
    
    /// UIImageView
    private lazy var imageView: UIImageView = {
        let _imageView: UIImageView = .init(image: image)
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
    
    /// UIButton
    private lazy var flipButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setImage(.init(named: "icns-flip"), for: .normal)
        _button.backgroundColor = .init(red: 34.0 / 255.0, green: 34.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
        _button.layer.cornerRadius = 16.0
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// bottomBar
    private lazy var bottomView: UIView = {
        let _view: UIView = .init()
        _view.backgroundColor = .init(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        return _view
    }()
    
    /// UIButton
    private lazy var retakeButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("重拍", for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// UIButton
    private lazy var confirmButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("确定", for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// 放大镜
    private var mMagnifier: ScanningMagnifierView?
    
    /// maxResizeSize
    private var maxResizeSize: CGSize {
        return .init(width: view.bounds.width * 0.95, height: view.bounds.height * 0.6)
    }
    
    /// UIImage
    private let cropModel: ScanningCropModel
    
    /// image
    private var image: UIImage {
        cropModel.image
    }
    
    /// 旋转角度
    private var originAngle: OriginAngle {
        cropModel.originAngle
    }

    //MARK: - 生命周期
    
    internal init(cropModel: ScanningCropModel) {
        self.cropModel = cropModel
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
    }
    
    internal override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if cropModel.cropImage != nil {
            imageView.transform = .init(rotationAngle: originAngle.counterclockwiseRotationAngle)
            imageView.frame = adjustResizeFrame()
            scanningCropView.transform = imageView.transform
            scanningCropView.frame = imageView.frame
            scanningCropView.position = cropModel.rectangle.convertRectangle(with: scanningCropView.bounds.size, scale: scanningCropView.bounds.width / image.size.width)
            scanningCropView.maxResizeFrame = scanningCropView.bounds
        } else {
            if let rectangleFeature = CIDetector.rectangle(with: image) {
                scanningCropView.position = Rectangle.convert(topLeft: rectangleFeature.topLeft,
                                                             topRight: rectangleFeature.topRight,
                                                             bottomLeft: rectangleFeature.bottomLeft,
                                                             bottomRight: rectangleFeature.bottomRight,
                                                             for: imageView)
            } else {
                scanningCropView.position = Rectangle.convert(topLeft: .init(x: 0, y: image.size.height),
                                                             topRight: .init(x: image.size.width, y: image.size.height),
                                                             bottomLeft: .zero,
                                                             bottomRight: .init(x: image.size.width, y: 0),
                                                             for: imageView)
            }
        }
    }

}

extension ScanningCropViewController {
    
    /// initialize
    private func initialize() {
        view.backgroundColor = .black
        
        view.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        let imageFrame = adjustResizeFrame()
        
        view.addSubview(imageView)
        imageView.frame = imageFrame
        
        view.addSubview(scanningCropView)
        scanningCropView.snp.makeConstraints {
            $0.edges.equalTo(imageView)
        }
        
        view.addSubview(flipButton)
        flipButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(32.0)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.top.equalTo(flipButton.snp.bottom).offset(24.0)
        }
        
        bottomView.addSubview(retakeButton)
        retakeButton.snp.makeConstraints {
            $0.bottom.top.equalTo(bottomView.safeAreaLayoutGuide)
            $0.left.equalTo(bottomView.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(49.0)
        }
        
        bottomView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.bottom.top.equalTo(bottomView.safeAreaLayoutGuide)
            $0.right.equalTo(bottomView.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(49.0)
        }
        
        
        view.layoutIfNeeded()
        
        scanningCropView.maxResizeFrame = scanningCropView.bounds
    }
    
    /// adjustResizeFrame
    /// - Returns: CGRect
    private func adjustResizeFrame() -> CGRect {
        let imgW = image.size.width
        let imgH = image.size.height
        let imgRadio = imgW / imgH
        switch originAngle {
        case .deg0, .deg180:
            var w: CGFloat
            var h: CGFloat
            if imgRadio >= 1.0 {
                w = maxResizeSize.width
                h = w / imgRadio
                if h > maxResizeSize.height {
                    h = maxResizeSize.height
                    w = h * imgRadio
                }
            } else {
                h = maxResizeSize.height
                w = h * imgRadio
                if w > maxResizeSize.width {
                    w = maxResizeSize.width
                    h = w / imgRadio
                }
            }
            return .init(x: (view.bounds.width - w) * 0.5, y: (view.bounds.height - h) * 0.5, width: w, height: h)
            
        case .deg90, .deg270:
            var w: CGFloat
            var h: CGFloat
            if imgRadio >= 1.0 {
                h = maxResizeSize.height
                w = h / imgRadio
                if w > maxResizeSize.width {
                    w = maxResizeSize.width
                    h = w * imgRadio
                }
            } else {
                w = maxResizeSize.width
                h = w * imgRadio
                if h > maxResizeSize.height {
                    h = maxResizeSize.height
                    w = h / imgRadio
                }
            }
            return .init(x: (view.bounds.width - w) * 0.5, y: (view.bounds.height - h) * 0.5, width: w, height: h)

        }
    }

    /// buttonActionHandler
    /// - Parameter button: UIButton
    @objc private func buttonActionHandler(_ button: UIButton) {
        switch button {
        case flipButton:
            cropModel.originAngle = originAngle.next
            UIView.animate(withDuration: 0.25) {
                self.imageView.transform = .init(rotationAngle: self.originAngle.counterclockwiseRotationAngle)
                self.imageView.frame = self.adjustResizeFrame()
                self.scanningCropView.transform = self.imageView.transform
                self.scanningCropView.frame = self.imageView.frame
                self.scanningCropView.adjustPosition()
            }
            
        case retakeButton:
            retakeActionHandler?()
            dismiss(animated: true)
            
        case confirmButton:
            let scale = image.size.width / imageView.bounds.width
            let rectangle = scanningCropView.position.convertRectangle(with: image.size, scale: scale)
            let image = crop(image: image, rectangle: rectangle, angle: originAngle.counterclockwiseRotationAngle)
            cropModel.originAngle = originAngle
            cropModel.rectangle = rectangle
            cropModel.cropImage = image
            reloadActionHandler?()
            dismiss(animated: true)
            
        default: break
        }

    }
    
    /// crop
    /// - Parameters:
    ///   - image: UIImage
    ///   - rectangle: Rectangle
    ///   - angle: CGFloat
    /// - Returns: UIImage
    private func crop(image: UIImage, rectangle: Rectangle, angle: CGFloat) -> UIImage {
        guard var ciImage: CIImage = .init(image: image) else { return image }
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

extension ScanningCropViewController: ScanningCropViewDelegate {
    
    /// cropBegin
    /// - Parameter point: CGPoint
    internal func cropBegin(at point: CGPoint) {
        if mMagnifier == nil {
            mMagnifier = ScanningMagnifierView.init(frame: .zero, at: imageView)
            mMagnifier?.adjustPoint = .init(x: 0, y: -15)
            mMagnifier?.originAngle = originAngle
            mMagnifier?.makeKeyAndVisible()
        }
        mMagnifier?.targetPoint = point
    }
    
    /// cropMoved
    /// - Parameter point: CGPoint
    internal func cropMoved(at point: CGPoint) {
        mMagnifier?.targetPoint = point
    }
    
    /// cropEnded
    internal func cropEnded(at point: CGPoint) {
        mMagnifier = nil
    }
}
