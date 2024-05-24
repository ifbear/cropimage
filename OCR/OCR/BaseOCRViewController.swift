//
//  BaseOCRViewController.swift
//  OCR
//
//  Created by dexiong on 2024/5/23.
//

import UIKit
import PhotosUI
import Vision
import Alamofire
import CryptoKit
import AlibabacloudOpenApi
import AlibabacloudOcrApi20210707

enum Service {
    case apple, tencent, ali
}


class BaseOCRViewController: UIViewController {
    
    
    private static let aliAccessKeyId: String = "**"
    private static let aliAccessKeySecret: String = "**"
    
    private static let tencentAccessKeyId: String = "**"
    private static let tencentAccessKeySecret: String = "**"
    
    private lazy var albumItem: UIBarButtonItem = .init(title: "相册", style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
    
    private lazy var showImageItem: UIBarButtonItem = .init(title: "显示图片", style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
    
    private lazy var appleItem: UIBarButtonItem = .init(title: "苹果", style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
    
    private lazy var tencentItem: UIBarButtonItem = .init(title: "腾讯", style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
    
    private lazy var aliItem: UIBarButtonItem = .init(title: "阿里", style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
    
    private(set) lazy var appleResultView: UITextView = {
        let _textView: UITextView = .init()
        _textView.isEditable = false
        _textView.isHidden = true
        return _textView
    }()
    
    private(set) lazy var tencentResultView: UITextView = {
        let _textView: UITextView = .init()
        _textView.isEditable = false
        _textView.isHidden = true
        return _textView
    }()
    
    private(set) lazy var aliResultView: UITextView = {
        let _textView: UITextView = .init()
        _textView.isEditable = false
        _textView.isHidden = true
        return _textView
    }()
    
    private lazy var toolBar: UIToolbar = {
        let _toolBar: UIToolbar = .init()
        _toolBar.items = [showImageItem, .flexibleSpace(), appleItem, .flexibleSpace(), tencentItem, .flexibleSpace(), aliItem]
        return _toolBar
    }()
    
    private lazy var imageView: UIImageView = {
        let _imageView: UIImageView = .init()
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
    
    private lazy var formatter: ByteCountFormatter = {
        let formatter: ByteCountFormatter = .init()
        formatter.countStyle = .file
        formatter.allowedUnits = .useAll
        return formatter
    }()
    
    private(set) lazy var alibabaClient: AlibabacloudOcrApi20210707.Client? = {
        let _config: Config = .init()
        _config.accessKeyId = Self.aliAccessKeyId
        _config.accessKeySecret = Self.aliAccessKeySecret
        _config.endpoint = "ocr-api.cn-hangzhou.aliyuncs.com"
        let _client: AlibabacloudOcrApi20210707.Client? = try? .init(_config)
        return _client
    }()
    
    private var service: Service = .apple
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.rightBarButtonItems = [albumItem]
        
        view.addSubview(appleResultView)
        appleResultView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.0)
        }
        
        view.addSubview(tencentResultView)
        tencentResultView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.0)
        }
        
        view.addSubview(aliResultView)
        aliResultView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.0)
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.0)
        }
        
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(49.0)
        }
    }
    
    internal func aliHandler(with image: UIImage) async {
        
    }
    
    internal func tencentHandler(with image: UIImage) {
        
    }
}

extension BaseOCRViewController {
    
    @objc private func itemActionHandler(_ item: UIBarButtonItem) {
        switch item {
        case albumItem:
            var configuration: PHPickerConfiguration = .init(photoLibrary: .shared())
            configuration.selectionLimit = 1
            configuration.filter = .images
            let controller: PHPickerViewController = .init(configuration: configuration)
            controller.delegate = self
            present(controller, animated: true)
        case showImageItem:
            navigationItem.title = ""
            imageView.isHidden = false
            appleResultView.isHidden = true
            tencentResultView.isHidden = true
            aliResultView.isHidden = true
            
        case appleItem:
            navigationItem.title = "苹果"
            service = .apple
            imageView.isHidden = true
            appleResultView.isHidden = false
            tencentResultView.isHidden = true
            aliResultView.isHidden = true
            
            if appleResultView.text.isEmpty == true, let image = imageView.image {
                appleHandler(with: image)
            }
            
        case tencentItem:
            navigationItem.title = "腾讯"
            service = .tencent
            imageView.isHidden = true
            appleResultView.isHidden = true
            tencentResultView.isHidden = false
            aliResultView.isHidden = true
            
            if tencentResultView.text.isEmpty == true, let image = imageView.image {
                tencentHandler(with: image)
            }
            
        case aliItem:
            navigationItem.title = "阿里"
            service = .ali
            imageView.isHidden = true
            appleResultView.isHidden = true
            tencentResultView.isHidden = true
            aliResultView.isHidden = false
            
            if aliResultView.text.isEmpty == true, let image = imageView.image {
                Task {
                    await aliHandler(with: image)
                }
            }
            
        default: break
        }
    }
}


extension BaseOCRViewController: PHPickerViewControllerDelegate {
    
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        let group: DispatchGroup = .init()
        group.enter()
        var _image: UIImage?
        result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            if let image = image as? UIImage {
                _image = image
            }
            group.leave()
        }
        group.notify(queue: .main) {
            guard let _image = _image else { return }
            self.imageView.image = _image
        }
    }
    
    
}

//MARK: - 苹果OCR
extension BaseOCRViewController {
    /// appleHandler
    /// - Parameter image: UIImage
    private func appleHandler(with image: UIImage) {
        DispatchQueue.global().async {
            guard let cgImage = image.cgImage else { return }
            let textRequest: VNRecognizeTextRequest = .init { request, error in
                DispatchQueue.main.async {
                    guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                    for observation in results {
                        var _text = ""
                        for text in observation.topCandidates(1) {
                            _text.append(text.string + " ")
                        }
                        self.appleResultView.text = self.appleResultView.text.appending(_text + "\n")
                    }
                }
            }
            
            do {
                textRequest.recognitionLevel = .accurate
                textRequest.usesLanguageCorrection = true
                if #available(iOS 16.0, *) {
                    textRequest.automaticallyDetectsLanguage = true
                } else {
                    textRequest.recognitionLanguages = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision2)
                }
                let requestHandler: VNImageRequestHandler = .init(cgImage: cgImage, options: [:])
                try requestHandler.perform([textRequest])
            } catch {
                print(error)
            }
        }
    }
    
}

//MARK: - 腾讯OCR
extension BaseOCRViewController {
    internal func sha256(msg: String) -> String {
        let data = msg.data(using: .utf8)!
        let digest = SHA256.hash(data: data)
        return digest.compactMap{String(format: "%02x", $0)}.joined()
    }
    
    internal func tencentAuthorization(for service: String, region: String, action: String, version: String, timestamp: Int, parameters: [String: Any]) -> String {
        let secretId = Self.tencentAccessKeyId
        let secretKey = Self.tencentAccessKeySecret
        let host = "\(service).tencentcloudapi.com"
        let algorithm = "ACS3-HMAC-SHA256"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
        
        // ************* 步骤 1：拼接规范请求串 *************
        let httpRequestMethod = "POST"
        let canonicalUri = "/"
        let canonicalQuerystring = ""
        let ct = "application/json; charset=utf-8"
        let payload = String(data: try! JSONSerialization.data(withJSONObject: parameters), encoding: .utf8) ?? "{}"
        let canonicalHeaders = "content-type:\(ct)\nhost:\(host)\nx-tc-action:\(action.lowercased())\n"
        let signedHeaders = "content-type;host;x-tc-action"
        let hashedRequestPayload = sha256(msg: payload)
        let canonicalRequest = """
            \(httpRequestMethod)
            \(canonicalUri)
            \(canonicalQuerystring)
            \(canonicalHeaders)
            \(signedHeaders)
            \(hashedRequestPayload)
            """
        print(canonicalRequest)
        
        // ************* 步骤 2：拼接待签名字符串 *************
        let credentialScope = "\(date)/\(service)/tc3_request"
        let hashedCanonicalRequest = sha256(msg: canonicalRequest)
        let stringToSign = """
            \(algorithm)
            \(timestamp)
            \(credentialScope)
            \(hashedCanonicalRequest)
            """
        print(stringToSign)
        
        // ************* 步骤 3：计算签名 *************
        let keyData = Data("TC3\(secretKey)".utf8)
        let dateData = Data(date.utf8)
        var symmetricKey = SymmetricKey(data: keyData)
        let secretDate = HMAC<SHA256>.authenticationCode(for: dateData, using: symmetricKey)
        let secretDateString = Data(secretDate).map{String(format: "%02hhx", $0)}.joined()
        print("\(secretDateString)")
        
        let serviceData = Data(service.utf8)
        symmetricKey = SymmetricKey(data: Data(secretDate))
        let secretService = HMAC<SHA256>.authenticationCode(for: serviceData, using: symmetricKey)
        let secretServiceString = Data(secretService).map{String(format: "%02hhx", $0)}.joined()
        print("\(secretServiceString)")
        
        let signingData = Data("tc3_request".utf8)
        symmetricKey = SymmetricKey(data: secretService)
        let secretSigning = HMAC<SHA256>.authenticationCode(for: signingData, using: symmetricKey)
        let secretSigningString = Data(secretSigning).map{String(format: "%02hhx", $0)}.joined()
        print("\(secretSigningString)")
        
        let stringToSignData = Data(stringToSign.utf8)
        symmetricKey = SymmetricKey(data: secretSigning)
        let signature = HMAC<SHA256>.authenticationCode(for: stringToSignData, using: symmetricKey).map{String(format: "%02hhx", $0)}.joined()
        print(signature)
        
        // ************* 步骤 4：拼接 Authorization *************
        let authorization = """
            \(algorithm) Credential=\(secretId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)
            """
        return authorization
    }
    
}
