//
//  DDSheetTableViewCell.swift
//  OCR
//
//  Created by dexiong on 2024/4/26.
//

import UIKit

class DDSheetTableViewCell: UITableViewCell {
    
    /// DDSheetItem?
    internal var item: DDSheetItem? {
        didSet { refreshUI() }
    }
    
    /// UILabel
    private lazy var label: UILabel = {
        let _label: UILabel = .init()
        _label.textAlignment = .center
        _label.numberOfLines = 0
        return _label
    }()
    
    /// init
    /// - Parameters:
    ///   - style: UITableViewCell.CellStyle
    ///   - reuseIdentifier: String?
    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        initialize()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}

extension DDSheetTableViewCell {
    
    /// initialize
    private func initialize() {
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    /// refreshUI
    private func refreshUI() {
        guard let item = item else { return }
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.pingfang(ofSize: 15.0), .foregroundColor: UIColor.black]

        if item.text.isEmpty == true {
            label.attributedText = .init(string: item.title, attributes: titleAttributes)
        } else {
            let attributesString: NSMutableAttributedString = .init(string: item.title, attributes: titleAttributes)
            let detailAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.pingfang(ofSize: 10.0), .foregroundColor: UIColor(hex: "#999999")]
            attributesString.append(.init(string: "\n\(item.text)", attributes: detailAttributes))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 0
            paragraphStyle.alignment = .center
            attributesString.addAttributes([.paragraphStyle: paragraphStyle], range: .init(location: 0, length: attributesString.string.count))
            label.attributedText = attributesString
        }
    }
}
