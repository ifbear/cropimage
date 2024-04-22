//
//  ScanningCropViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/16.
//

import UIKit

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
    
    /// 旋转角度
    private var originAngle: OriginAngle = .deg0
    
    /// maxResizeSize
    private var maxResizeSize: CGSize {
        return .init(width: view.bounds.width * 0.95, height: view.bounds.height * 0.6)
    }
    
    /// UIImage
    private let image: UIImage

    //MARK: - 生命周期
    
    internal init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
        if let rectangleFeature = CIDetector.rectangle(with: image) {
            scanningCropView.position = Position.convert(topLeft: rectangleFeature.topLeft, 
                                                         topRight: rectangleFeature.topRight,
                                                         bottomLeft: rectangleFeature.bottomLeft,
                                                         bottomRight: rectangleFeature.bottomRight,
                                                         for: imageView)
        } else {
            scanningCropView.position = Position.convert(topLeft: .init(x: 0, y: image.size.height), 
                                                         topRight: .init(x: image.size.width, y: image.size.height),
                                                         bottomLeft: .zero, 
                                                         bottomRight: .init(x: image.size.width, y: 0),
                                                         for: imageView)
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
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(imageFrame.width)
            $0.height.equalTo(imageFrame.height)
        }
        
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
        
        scanningCropView.imageEdgeRect = imageView.contentClippingRect
        scanningCropView.maxResizeFrame = scanningCropView.bounds
    }
    
    /// adjustPosition
    private func adjustPosition() {
        let position = scanningCropView.position
        let rect = scanningCropView.bounds
        let scale = rect.height / scanningCropView.maxResizeFrame.height
        let topLeft: CGPoint = .init(x: position.topLeft.x * scale, y: position.topLeft.y * scale)
        let topRight: CGPoint = .init(x: position.topRight.x * scale, y: position.topRight.y * scale)
        let bottomLeft: CGPoint = .init(x: position.bottomLeft.x * scale, y: position.bottomLeft.y * scale)
        let bottomRight: CGPoint = .init(x: position.bottomRight.x * scale, y: position.bottomRight.y * scale)
        scanningCropView.position = .init(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        scanningCropView.layer.setNeedsDisplay()
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
            originAngle = originAngle.next
            UIView.animate(withDuration: 0.25) {
                self.imageView.transform = .init(rotationAngle: self.originAngle.counterclockwiseRotationAngle)
                self.imageView.frame = self.adjustResizeFrame()
                self.scanningCropView.transform = self.imageView.transform
                self.scanningCropView.frame = self.imageView.frame
                self.adjustPosition()
            } completion: { _ in
            }
            
        case retakeButton:
            retakeActionHandler?()
            dismiss(animated: true)
            
        case confirmButton:
            reloadActionHandler?()
            dismiss(animated: true)
            
        default: break
        }

    }
    
    @objc private func itemActionHandler(_ item: UIBarButtonItem) {
//        let position = scanningCropView.position
//        let scale = image.size.width / imageView.bounds.width
//        let image = CIImage.applyingFilter(image: image, rectangle: (position.topLeft.convertToCoreImage(imageSize: image.size, scale: scale),
//                                                         position.topRight.convertToCoreImage(imageSize: image.size, scale: scale),
//                                                         position.bottomLeft.convertToCoreImage(imageSize: image.size, scale: scale),
//                                                         position.bottomRight.convertToCoreImage(imageSize: image.size, scale: scale)))
//        self.imageView.image = image
//        self.scanningCropView.layer.setNeedsDisplay()
    }
}

extension ScanningCropViewController: ScanningCropViewDelegate {
    
    /// cropBegin
    /// - Parameter point: CGPoint
    internal func cropBegin(at point: CGPoint) {
        if mMagnifier == nil {
            mMagnifier = ScanningMagnifierView.init(frame: .zero, at: imageView)
            mMagnifier?.adjustPoint = .init(x: 0, y: -15)
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
