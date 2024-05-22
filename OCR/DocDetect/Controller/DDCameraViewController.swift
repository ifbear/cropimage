//
//  DDCameraViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/22.
//

import UIKit
import AVFoundation

extension DDCameraViewController {
    
    /// showDocumentDetectController
    /// - Parameter target: UIViewController
    internal static func showDocumentDetectController(at target: UIViewController, complateBlock: (([URL]) -> Void)? = nil) {
        let controller: DDCameraViewController = .init()
        controller.complateBlock = complateBlock
        let navi: DDNavigationController = .init(rootViewController: controller)
        target.present(navi, animated: true)
    }
}

class DDCameraViewController: UIViewController {
    
    /// ([URL]) -> Void
    internal var complateBlock: (([URL]) -> Void)? = nil
    
    /// flashButton
    private lazy var flashButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setImage(.init(named: "icns-flash")?.withRenderingMode(.alwaysTemplate), for: .normal)
        _button.setImage(.init(named: "icns-flash"), for: .selected)
        _button.tintColor = .white
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// albumButton
    private lazy var albumButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("相册", for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// videoLayerView
    private lazy var videoLayerView: UIView = {
        let _view: UIView = .init()
        return _view
    }()
    
    /// bottomView
    private lazy var bottomView: UIView = {
        let _view: UIView = .init()
        _view.backgroundColor = .black
        return _view
    }()
    
    /// cancelButton
    private lazy var cancelButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("取消", for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// takeButton
    private lazy var takeButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setImage(.init(named: "icns-takepicture"), for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// previewButton
    private lazy var previewButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("已扫描", for: .normal)
        _button.setImage(.init(named: "icns-arrow"), for: .normal)
        _button.semanticContentAttribute = .forceRightToLeft
        _button.isHidden = true
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// imageView
    private lazy var imageView: UIImageView = {
        let _view: UIImageView = .init()
        _view.contentMode = .scaleAspectFit
        _view.layer.borderWidth = 2.0
        _view.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        _view.isHidden = true
        return _view
    }()
    
    /// session
    private lazy var session: AVCaptureSession = {
        let session: AVCaptureSession = .init()
        session.sessionPreset = .vga640x480
        return session
    }()
    
    /// deviceInput
    private var deviceInput: AVCaptureDeviceInput?
    
    /// photoOutput
    private lazy var photoOutput: AVCapturePhotoOutput = {
        let _output: AVCapturePhotoOutput = .init()
        return _output
    }()
    
    /// output
    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let _output: AVCaptureVideoDataOutput = .init()
        _output.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        _output.alwaysDiscardsLateVideoFrames = true
        _output.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
        return _output
    }()
    
    /// previewLayer
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let _layer: AVCaptureVideoPreviewLayer = .init(session: session)
        _layer.videoGravity = .resizeAspectFill
        return _layer
    }()
    
    /// sessionQueue
    private let sessionQueue: DispatchQueue = .init(label: "AVCaptureSession.sessionQueue")
    
    /// videoDataOutputQueue
    private let videoDataOutputQueue: DispatchQueue = .init(label: "AVCaptureVideoDataOutput.videoDataOutputQueue")
    
    /// cropModels
    private var cropModels: [DDCropModel] {
        get { (navigationController as! DDNavigationController).cropModels }
        set {
            (navigationController as! DDNavigationController).cropModels = newValue
            previewButton.isHidden = newValue.isEmpty
            previewButton.setTitle("已扫描\(newValue.count)", for: .normal)
        }
    }
    
    /// OpenCVUtils
    private lazy var openCVUtils: OpenCVUtils = .init()
    
    /// _isScanning
    private var _isScanning: Bool = false
    
    /// isScanning
    private var isScanning: Bool {
        get { Utils.synchronized(for: self) { _isScanning } }
        set { Utils.synchronized(for: self) { _isScanning = newValue } }
    }
    
    //MARK: - 生命周期
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
        // 获取摄像头状态
        requestCameraStatus { [unowned self] finish in
            guard finish == true else { return }
            initSession()
        }
    }
    
    /// viewWillAppear
    /// - Parameter animated: Bool
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined {
            startRunning()
        }
        // 刷新
        previewButton.isHidden = cropModels.isEmpty
        previewButton.setTitle("已扫描\(cropModels.count)", for: .normal)
    }
    
    /// viewWillDisappear
    /// - Parameter animated: Bool
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}

extension DDCameraViewController {
    
    /// initialize
    private func initialize() {
        view.backgroundColor = .black
        navigationItem.leftBarButtonItem = .init(customView: flashButton)
        navigationItem.rightBarButtonItem = .init(customView: albumButton)
        
        view.addSubview(videoLayerView)
        videoLayerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(videoLayerView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        bottomView.addSubview(takeButton)
        takeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(65.0)
            $0.top.equalTo(bottomView).offset(49.0)
            $0.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        
        bottomView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16.0)
            $0.centerY.equalTo(takeButton.snp.centerY)
            $0.height.equalTo(49.0)
        }

        bottomView.addSubview(previewButton)
        previewButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16.0)
            $0.centerY.equalTo(takeButton.snp.centerY)
            $0.height.equalTo(49.0)
        }
        
        view.layoutIfNeeded()
    }
    
    /// 初始化session
    private func initSession() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.beginConfiguration()
        self.deviceInput = input
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        /// addOutput videoDataOutput
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        if let connection = videoDataOutput.connection(with: .video), connection.hub.isVideoOrientationSupported {
            connection.hub.videoOrientation = .portrait
        }
        
//        /// addOutput photoOutput
//        if session.canAddOutput(photoOutput) {
//            session.addOutput(photoOutput)
//        }
//        if let connection = photoOutput.connection(with: .video), connection.hub.isVideoOrientationSupported {
//            connection.hub.videoOrientation = .portrait
//        }
        
        /// previewLayer
        previewLayer.frame = videoLayerView.bounds
        videoLayerView.layer.insertSublayer(previewLayer, at: 0)
        if let connection = previewLayer.connection, connection.hub.isVideoOrientationSupported {
            connection.hub.videoOrientation = .portrait
        }
        session.commitConfiguration()
        
        startRunning()
    }
    
    /// startRunning
    private func startRunning() {
        sessionQueue.async { [weak self] in
            guard let this = self else { return }
            guard this.session.isRunning == false else { return }
            this.session.startRunning()
        }
    }
    
    /// stopRunning
    private func stopRunning() {
        sessionQueue.async { [weak self] in
            guard let this = self else { return }
            guard this.session.isRunning == true else { return }
            this.session.stopRunning()
        }
    }
    
    /// requestCameraStatus
    /// - Parameter handler: (Bool) -> Void
    private func requestCameraStatus(_ handler: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                DispatchQueue.main.async {
                    self.requestCameraStatus(handler)
                }
            }
        case .restricted, .denied:
            let controller: UIAlertController = .init(title: "梯形", message: "请到设置里开启相机权限", preferredStyle: .alert)
            controller.addAction(.init(title: "取消", style: .cancel))
            controller.addAction(.init(title: "去开启", style: .default, handler: { _ in
                guard let url: URL = .init(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }))
            present(controller, animated: true)

        case .authorized:
            handler(true)
            
        @unknown default:
            handler(false)
        }
    }
    
    /// buttonActionHandler
    /// - Parameter button: UIButton
    @objc private func buttonActionHandler(_ button: UIButton) {
        switch button {
        case flashButton:
            button.isSelected.toggle()
            
        case albumButton:
            break
            
        case cancelButton:
            dismiss(animated: true)
            
        case takeButton:
            guard let connection = photoOutput.connection(with: .video) else { return }
            connection.videoOrientation = .portrait
            let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            
            if deviceInput?.device.hasFlash == true, flashButton.isSelected {
                setting.flashMode = .on
            } else {
                setting.flashMode = .off
            }
            photoOutput.capturePhoto(with: setting, delegate: self)

        case previewButton:
            let controller: DDPreviewController = .init()
            controller.complateBlock = complateBlock
            navigationController?.pushViewController(controller, animated: true)
            
        default: break
        }
    }
}

//MARK: - AVCapturePhotoCaptureDelegate
extension DDCameraViewController: AVCapturePhotoCaptureDelegate {
    
    /// didFinishProcessingPhoto
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - photo: AVCapturePhoto
    ///   - error: (any Error)?
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data)?.hub.fixOrientation() else { return }
        let model: DDCropModel = .init(image: image)
        let controller: DDCropViewController = .init(cropModel: model)
        controller.reloadActionHandler = { [weak self] in
            self?.cropModels.append(model)
        }
        controller.retakeActionHandler = { [weak self] in
            guard let index = self?.cropModels.firstIndex(of: model) else { return }
            self?.cropModels.remove(at: index)
        }
        let navi: UINavigationController = .init(rootViewController: controller)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }
    
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension DDCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// didOutput
    /// - Parameters:
    ///   - output: AVCaptureOutput
    ///   - sampleBuffer: CMSampleBuffer
    ///   - connection: AVCaptureConnection
    internal func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanning == false else { return }
        isScanning = true
        openCVUtils.processCVImageBuffer(sampleBuffer, callbackQueue: .main) { [weak self] (points, image) in
            guard let this = self, let points = points, let image = image else {
                self?.isScanning = false
                return
            }
            let cgPoints = points.map(\.cgPointValue).map { point in
                return point.convert(for: image.size, scaleBy: 1)
            }
            this.crop(image: image, points: cgPoints)
        }
    }
    
    /// crop
    /// - Parameters:
    ///   - image: UIImage
    ///   - points: [CGPoint]]
    private func crop(image: UIImage, points: [CGPoint]) {
        let position: Rectangle = .init(topLeft: points[0], topRight: points[1], bottomLeft: points[3], bottomRight: points[2])
        guard position.checkValid() == true else {
            isScanning = false
            return
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
        let cropImage = image.hub.crop(rectangle: position, angle: 0)
        imageView.isHidden = false
        imageView.image = cropImage
        let bounds = view.bounds
        let imgW: CGFloat
        let imgH: CGFloat
        if cropImage.size.width / cropImage.size.height >= 1.0 {
            imgW = bounds.width * 0.75
            imgH = cropImage.size.height / cropImage.size.width * imgW
        } else {
            imgH = bounds.width * 0.75
            imgW = cropImage.size.width / cropImage.size.height * imgH
        }
        view.addSubview(imageView)
        view.bringSubviewToFront(bottomView)
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.imageView.frame = .init(x: (bounds.width - imgW) * 0.5, y: (bounds.height - imgH) * 0.5, width: imgW, height: imgH)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: [.curveEaseIn], animations: { [weak self] in
                self?.imageView.transform = .init(translationX: bounds.width * 0.5 - 20, y: bounds.height * 0.5).scaledBy(x: 0.1, y: 0.1)
            }, completion: { [weak self] _ in
                self?.cropModels.append(.init(image: image, cropImage: cropImage, cropPosition: position))
                // 从视图层次结构中移除截屏视图
                self?.imageView.removeFromSuperview()
                self?.imageView.transform = .identity
                self?.imageView.isHidden = true
                self?.view.isUserInteractionEnabled = true
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [weak self] in
            self?.isScanning = false
        }
    }
}
