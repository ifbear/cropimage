//
//  OpenCVPictureOutlineViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/12.
//

import UIKit
import PhotosUI
import CoreImage

class OpenCVPictureOutlineViewController: UIViewController {

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

extension OpenCVPictureOutlineViewController {
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
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                

            } catch {
                print(error)
            }
        }
    }
    
}


extension OpenCVPictureOutlineViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.isEmpty == false else { return }
        guard let result = results.first else { return }
        _ = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: recognize())
    }
}

extension OpenCVPictureOutlineViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
}
