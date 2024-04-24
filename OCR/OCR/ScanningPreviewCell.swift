//
//  ScanningPreviewCell.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import UIKit

/// ScanningPreviewCell
class ScanningPreviewCell: UICollectionViewCell {
    
    /// cropModel
    internal var cropModel: ScanningCropModel? {
        didSet { reloadUI() }
    }
    
    //MARK: - 私有属性
    
    /// closeButton
    private lazy var closeButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setImage(.init(named: "icns-close"), for: .normal)
        _button.imageView?.contentMode = .center
        return _button
    }()
    
    /// imageView
    private lazy var imageView: UIImageView = {
        let _imageView: UIImageView = .init()
        _imageView.contentMode = .scaleToFill
        _imageView.clipsToBounds = true
        return _imageView
    }()
    
    /// ocrButton
    private lazy var ocrButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setImage(.init(named: "icns-image-ocr"), for: .normal)
        _button.backgroundColor = .black.withAlphaComponent(0.4)
        _button.layer.cornerRadius = 16.0
        return _button
    }()
    
    //MARK: - 生命周期
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ScanningPreviewCell {
    
    /// initialize
    private func initialize() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20.0)
        }
        
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.height.width.equalTo(40.0)
        }
        
        contentView.addSubview(ocrButton)
        ocrButton.snp.makeConstraints {
            $0.bottom.equalTo(imageView).offset(-16.0)
            $0.right.equalTo(imageView).offset(-16.0)
            $0.height.width.equalTo(32.0)
        }
    }
    
    /// reloadUI
    private func reloadUI() {
        imageView.image = cropModel?.cropImage
    }
}
