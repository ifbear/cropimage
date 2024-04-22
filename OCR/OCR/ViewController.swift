//
//  ViewController.swift
//  OCR
//
//  Created by dexiong on 2024/3/25.
//

import UIKit
import SnapKit
import PhotosUI

class ViewController: UIViewController {
    
    private lazy var sysTextView: UITextView = {
        let textView: UITextView = .init()
        textView.backgroundColor = .lightGray
        return textView
    }()
    
    private lazy var sysBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setTitle("系统", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return btn
    }()

    private lazy var aliTextView: UITextView = {
        let textView: UITextView = .init()
        textView.backgroundColor = .lightGray
        return textView
    }()
    
    private lazy var aliBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setTitle("阿里", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var mode: Optional<Mode> = .none
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sysBtn)
        sysBtn.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(32.0)
        }
        
        view.addSubview(sysTextView)
        sysTextView.snp.makeConstraints {
            $0.top.equalTo(sysBtn.snp.bottom)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY)
        }
        
        view.addSubview(aliBtn)
        aliBtn.snp.makeConstraints {
            $0.top.equalTo(sysTextView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(32.0)
        }
        view.addSubview(aliTextView)
        aliTextView.snp.makeConstraints {
            $0.top.equalTo(aliBtn.snp.bottom)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

}
extension ViewController {
    @objc private func buttonActionHandler(_ btn: UIButton) {
        switch btn {
        case sysBtn:
            mode = .system

        case aliBtn:
            mode = .aliyun
            
        default: break
        }
        
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
    }
    
    private func recognize(url: URL)  {
        guard let mode = mode else { return }
        try? OCRTool.shared.recognize(url: url, mode: mode, callbackQueue: .main) { [unowned self] text in
            if mode == .system {
                self.sysTextView.text = text
            } else if mode == .aliyun {
                self.aliTextView.text = text
            }
        }
    }
    
    private func recognize() -> (URL?, Error?) -> Void {
        return { [unowned self] url, error in
            do {
                guard let url = url else { return }
                let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("temp.png")
                try? FileManager.default.removeItem(at: tempUrl)
                try FileManager.default.copyItem(at: url, to: tempUrl)
                guard let mode = mode else { return }
                try? OCRTool.shared.recognize(url: tempUrl, mode: mode, callbackQueue: .main) { [unowned self] text in
                    if mode == .system {
                        self.sysTextView.text = text
                    } else if mode == .aliyun {
                        self.aliTextView.text = text
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.isEmpty == false else { return }
        guard let result = results.first else { return }
        _ = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: recognize())
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
}
