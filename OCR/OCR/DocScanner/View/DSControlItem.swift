//
//  DSControlItem.swift
//  OCR
//
//  Created by dexiong on 2024/4/25.
//

import UIKit

class DSControlItem: UIControl {
    
    /// image
    internal var image: UIImage? {
        didSet { imageView.image = image?.withRenderingMode(.alwaysTemplate) }
    }
    
    /// text
    internal var text: String? {
        didSet { textLabel.text = text }
    }
    
    internal override var isEnabled: Bool {
        didSet { 
            if isEnabled {
                textLabel.textColor = .black
                imageView.tintColor = .black
            } else {
                textLabel.textColor = .gray
                imageView.tintColor = .gray
            }
        }
    }
    
    /// imageView
    private lazy var imageView: UIImageView = {
        let _view: UIImageView = .init()
        _view.tintColor = .black
        return _view
    }()
    
    /// textLabel
    private lazy var textLabel: UILabel = {
        let _label: UILabel = .init()
        return _label
    }()

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DSControlItem {
    
    /// initialize
    private func initialize() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(28.0)
            $0.top.equalToSuperview().offset(12.0)
        }
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(8.0)
            $0.bottom.equalToSuperview().offset(-12.0)
        }
    }
}
