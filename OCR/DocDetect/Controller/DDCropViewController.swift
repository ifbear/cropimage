//
//  DDCropViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/16.
//

import UIKit
import CoreGraphics

extension DDCropViewController {
    enum Source {
        case camera, album
    }
}

class DDCropViewController: UIViewController {
    
    /// 重拍回调
    internal var retakeActionHandler: (() -> Void)? = nil
    
    /// 编辑完成回调
    internal var reloadActionHandler: (() -> Void)? = nil
    
    /// scanningCropView
    private lazy var scanningCropView: DDCropView = {
        let _view: DDCropView = .init(frame: view.bounds, image: image)
        _view.delegate = self
        return _view
    }()
    
    /// UILabel
    private lazy var titleView: UILabel = {
        let _label: UILabel = .init()
        _label.text = "拖动圆点调整边缘"
        _label.font = .pingfang(ofSize: 17.0)
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
        _button.setTitle(source == .camera ? "重拍" : "重选", for: .normal)
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
    
    /// OpenCVUtils
    private lazy var openCVUtils: OpenCVUtils = .init()
    
    /// 放大镜
    private var mMagnifier: DDMagnifierView?
    
    /// maxResizeSize
    private var maxResizeSize: CGSize {
        return .init(width: view.bounds.width * 0.95, height: view.bounds.height * 0.6)
    }
    
    /// UIImage
    private let cropModel: DDCropModel
    
    /// 来源
    private let source: Source
    
    /// image
    private var image: UIImage {
        cropModel.image
    }
    
    /// 旋转角度
    private var originAngle: OriginAngle {
        cropModel.originAngle
    }
    
    //MARK: - 生命周期
    
    /// init
    /// - Parameters:
    ///   - cropModel: DDCropModel
    ///   - source: Source
    internal init(cropModel: DDCropModel, source: Source = .camera) {
        self.cropModel = cropModel
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    /// init corder
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
    }
    
    /// viewIsAppearing
    /// - Parameter animated: Bool
    internal override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        refreshUI()
    }
    
    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}

extension DDCropViewController {
    
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
    
    /// refreshUI
    private func refreshUI() {
        func handler(_ rectangle: Rectangle) {
            imageView.transform = .init(rotationAngle: originAngle.counterclockwiseRotationAngle)
            imageView.frame = adjustResizeFrame()
            scanningCropView.transform = imageView.transform
            scanningCropView.frame = imageView.frame
            scanningCropView.position = rectangle.convertRectangle(with: scanningCropView.bounds.size, scale: scanningCropView.bounds.width / image.size.width)
            scanningCropView.maxResizeFrame = scanningCropView.bounds
        }
        if cropModel.cropImage != nil {
            handler(cropModel.rectangle)
        } else {
            openCVUtils.processUIImage(image, callbackQueue: .main) { [weak self] points, image in
                guard let this = self else { return }
                if let points = points, let image = image {
                    let cgPoints = points.map(\.cgPointValue).map { point in
                        return point.convert(for: image.size, scaleBy: 1)
                    }
                    this.cropModel.image = image
                    this.imageView.image = image
                    handler(.init(topLeft: cgPoints[0],
                                  topRight: cgPoints[1],
                                  bottomLeft: cgPoints[3],
                                  bottomRight: cgPoints[2]))
                } else {
                    let maxX = this.image.size.width - 10
                    let maxY = this.image.size.height - 10
                    handler(.init(topLeft: .init(x: 10, y: maxY),
                                  topRight: .init(x: maxX, y: maxY),
                                  bottomLeft: .init(x: 10, y: 10),
                                  bottomRight: .init(x: maxX, y: 10)))
                }
            }
        }
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
            guard scanningCropView.position.checkValid() == true else { return }
            let scale = image.size.width / imageView.bounds.width
            let rectangle = scanningCropView.position.convertRectangle(with: image.size, scale: scale)
            let image = image.hub.crop(rectangle: rectangle, angle: originAngle.counterclockwiseRotationAngle)
            cropModel.originAngle = originAngle
            cropModel.rectangle = rectangle
            cropModel.cropImage = image
            reloadActionHandler?()
            dismiss(animated: true)
            
        default: break
        }
        
    }
    
}

//MARK: - DDCropViewDelegate
extension DDCropViewController: DDCropViewDelegate {
    
    /// cropBegin
    /// - Parameter point: CGPoint
    internal func cropBegin(at point: CGPoint) {
        if mMagnifier == nil {
            mMagnifier = DDMagnifierView.init(frame: .zero, at: imageView)
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
