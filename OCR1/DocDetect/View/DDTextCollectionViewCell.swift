//
//  DDTextCollectionViewCell.swift
//  OCR
//
//  Created by dexiong on 2024/4/24.
//

import UIKit

class DDTextCollectionViewCell: UICollectionViewCell {
    
    /// text
    internal var model: DDOcrModel? {
        didSet { refreshUI() }
    }
    
    /// isSelected
    internal override var isSelected: Bool {
        didSet {
            backgroundView?.backgroundColor = isSelected ? .init(hex: "#EBF0FB") : .init(hex: "#F7F7F7")
            textlabel.isHighlighted = isSelected
        }
    }
    
    /// textlabel
    private lazy var textlabel: UILabel = {
        let _label: UILabel = .init()
        _label.textAlignment = .center
        _label.textColor = .init(hex: "#333333")
        _label.highlightedTextColor = .init(hex: "#3D69DB")
        _label.font = .pingfang(ofSize: 17.0)
        return _label
    }()
    
    //MARK: - 生命周期
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}

extension DDTextCollectionViewCell {
    
    /// initialize
    private func initialize() {
        backgroundView = .init()
        backgroundView?.layer.cornerRadius = 2.0
        
        contentView.addSubview(textlabel)
        textlabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10.0)
            $0.top.bottom.equalToSuperview().inset(5.0)
        }
    }
    
    /// updateUI
    private func refreshUI() {
        guard let model = model else { return }
        textlabel.text = model.text
        textlabel.isHighlighted = model.isSelected
    }
}
