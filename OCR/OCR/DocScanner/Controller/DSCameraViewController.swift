//
//  DSCameraViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/22.
//

import UIKit
import AVFoundation

extension Notification.Name {
    
    /// corpModelDeleted
    internal static var corpModelDeleted: Notification.Name = .init(rawValue: "Notification.Name.corpModelDeleted")
}

class DSCameraViewController: UIViewController {
    
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
    
    /// scannedButton
    private lazy var scannedButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("已扫描", for: .normal)
        _button.setImage(.init(named: "icns-arrow"), for: .normal)
        _button.semanticContentAttribute = .forceRightToLeft
        _button.isHidden = true
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// session
    private lazy var session: AVCaptureSession = {
        let session: AVCaptureSession = .init()
        session.sessionPreset = .vga640x480
        return session
    }()
    
    /// input
    private var input: AVCaptureDeviceInput?
    
    /// output
    private var output: AVCapturePhotoOutput?
    
    /// previewLayer
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// sessionQueue
    private let sessionQueue: DispatchQueue = .init(label: "AVCaptureSession.sessionQueue")
    
    /// cropModels
    private var cropModels: [DSCropModel] = [] {
        didSet {
            scannedButton.isHidden = cropModels.isEmpty
            scannedButton.setTitle("已扫描\(cropModels.count)", for: .normal)
        }
    }
    
    //MARK: - 生命周期
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()

        requestCameraStatus { [unowned self] finish in
            guard finish == true else { return }
            initSession()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(Self.notificationActionHandler(_:)), name: .corpModelDeleted, object: nil)
    }

    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined else { return }
        sessionQueue.async {
            guard self.session.isRunning == false else { return }
            self.session.startRunning()
        }
    }

    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
    
    deinit {
        print(#function, #file)
        NotificationCenter.default.removeObserver(self)
    }
}

extension DSCameraViewController {
    
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

        bottomView.addSubview(scannedButton)
        scannedButton.snp.makeConstraints {
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
        self.input = input
        if session.canAddInput(input) {
            session.addInput(input)
        }
        let output = AVCapturePhotoOutput()
        self.output = output
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        previewLayer = .init(session: session)
        previewLayer?.frame = videoLayerView.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            videoLayerView.layer.insertSublayer(previewLayer, at: 0)
        }
        session.commitConfiguration()
        
        sessionQueue.async {
            self.session.startRunning()
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
            guard let connection = output?.connection(with: .video) else { return }
            connection.videoOrientation = .portrait
            let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            if input?.device.hasFlash == true, flashButton.isSelected {
                setting.flashMode = .on
            } else {
                setting.flashMode = .off
            }
            output?.capturePhoto(with: setting, delegate: self)
        case scannedButton:
            let controller: DSPreviewController = .init(cropModels: cropModels)
            navigationController?.pushViewController(controller, animated: true)
        default: break
        }
    }
    
    @objc private func notificationActionHandler(_ noti: Notification) {
        switch noti.name {
        case .corpModelDeleted:
            guard let model = noti.userInfo?["model"] as? DSCropModel, let index = cropModels.firstIndex(of: model) else { return }
            cropModels.remove(at: index)
            
        default: break
        }
    }
}

extension DSCameraViewController: AVCapturePhotoCaptureDelegate {
    
    /// didFinishProcessingPhoto
    /// - Parameters:
    ///   - output: AVCapturePhotoOutput
    ///   - photo: AVCapturePhoto
    ///   - error: (any Error)?
    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data)?.hub.fixOrientation() else { return }
        let model: DSCropModel = .init(image: image)
        let controller: DSCropViewController = .init(cropModel: model)
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
