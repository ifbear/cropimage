//
//  DDQuickLookViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/28.
//

import UIKit
import QuickLook

extension DDQuickLookViewController {
    
    /// PreviewItem
    class PreviewItem: NSObject, QLPreviewItem {
        
        /// file
        internal let file: URL
        
        /// name
        internal let name: String?
        
        
        /// previewItemURL
        internal var previewItemURL: URL? {
            return file
        }
        
        /// previewItemTitle
        internal var previewItemTitle: String? {
            return name ?? file.lastPathComponent
        }
        
        internal init(file: URL, name: String? = nil) {
            self.file = file
            self.name = name
        }
    }
}

class DDQuickLookViewController: UIViewController {
    
    /// UIBarButtonItem
    private lazy var backItem: UIBarButtonItem = {
        let _img: UIImage? = .init(named: "icns-back")?.withTintColor(.black)
        let _btn: UIButton = .init(type: .custom)
        _btn.setImage(_img, for: .normal)
        let lr = (44.0 - (_img?.size.width ?? 0)) * 0.5
        _btn.imageEdgeInsets = .init(top: 0, left: -lr, bottom: 0, right: lr)
        _btn.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        _btn.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return .init(customView: _btn)
    }()
    
    /// QLPreviewController
    private lazy var previewController: QLPreviewController = {
        let _controller: QLPreviewController = .init()
        _controller.view.backgroundColor = .white
        _controller.dataSource = self
        _controller.addObserver(self, forKeyPath: #keyPath(QLPreviewController.currentPreviewItemIndex), options: [.new], context: nil)
        return _controller
    }()
    
    /// UIButton
    private lazy var confirmButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("立即添加至邮件", for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
        _button.backgroundColor = .init(hex: "#3D69DB")
        _button.layer.cornerRadius = 20.0
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// UILabel
    private lazy var titleView: UILabel = {
        let _label: UILabel = .init()
        _label.numberOfLines = 0
        _label.textAlignment = .center
        _label.attributedText = attributesTitle(for: 0)
        _label.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        _label.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        return _label
    }()
    
    /// [PreviewItem]
    private let items: [PreviewItem]
    
    /// (Bool) -> Void
    private let confirmActionHandler: (Bool) -> Void
    
    /// init
    /// - Parameter items: [PreviewItem]
    internal init(items: [PreviewItem], confirm actionHandler: @escaping (Bool) -> Void) {
        self.items = items
        self.confirmActionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    /// observeValue
    /// - Parameters:
    ///   - keyPath: String
    ///   - object: Any
    ///   - change: [NSKeyValueChangeKey : Any]
    ///   - context: UnsafeMutableRawPointer
    internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case #keyPath(QLPreviewController.currentPreviewItemIndex):
            guard let index = change?[.newKey] as? Int else { return }
            
            titleView.attributedText = attributesTitle(for: index)
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        previewController.removeObserver(self, forKeyPath: #keyPath(QLPreviewController.currentPreviewItemIndex))
        print(#function, #file.hub.lastPathComponent)
    }

}

extension DDQuickLookViewController {
    
    /// initialize
    private func initialize() {
        view.backgroundColor = .white
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = backItem
        
        previewController.view.backgroundColor = .white
        addChild(previewController)
        view.addSubview(previewController.view)
        previewController.view.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(previewController.view.snp.bottom).offset(8.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8.0)
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(40.0)
            $0.height.equalTo(40.0)
        }
    }
    
    /// attributesTitle
    /// - Returns: NSAttributedString
    private func attributesTitle(for index: Int) -> NSAttributedString {
        guard items.count > index else { return .init(string: "预览", attributes: [.font: UIFont.pingfang(ofSize: 17.0, weight: .medium)]) }
        let attributesTitle: NSMutableAttributedString = .init(string: "预览\n", attributes: [.font: UIFont.pingfang(ofSize: 17.0, weight: .medium)])
        attributesTitle.append(.init(string: "\(items[index].previewItemTitle ?? "") \(index)", attributes: [.font: UIFont.pingfang(ofSize: 10.0, weight: .regular), .foregroundColor: UIColor(hex: "#888888")]))
        return attributesTitle
    }
    
    /// buttonActionHandler
    /// - Parameter btn: UIButton
    @objc private func buttonActionHandler(_ btn: UIButton) {
        switch btn {
        case backItem.customView:
            dismiss(animated: true) { [weak self] in
                self?.confirmActionHandler(false)
            }
            
        case confirmButton:
            dismiss(animated: true) { [weak self] in
                self?.confirmActionHandler(true)
            }
            
        default: break
        }
    }
}

extension DDQuickLookViewController: QLPreviewControllerDataSource {
    
    /// numberOfPreviewItems
    /// - Parameter controller: QLPreviewController
    /// - Returns: Int
    internal func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }
    
    /// previewItemAt
    /// - Parameters:
    ///   - controller: QLPreviewController
    ///   - index: Int
    /// - Returns: QLPreviewItem
    internal func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        return items[index]
    }
    
    
}
