//
//  DDSheetViewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/26.
//

import UIKit
import PanModal

class DDSheetViewController: UIViewController {

    private lazy var headerLabel: UILabel = {
        let _label: UILabel = .init()
        _label.textColor = .init(hex: "#999999")
        _label.font = .pingfang(ofSize: 14.0)
        _label.text = "选择导出文件格式"
        return _label
    }()
    
    private lazy var tableView: UITableView = {
        let _tableView: UITableView = .init(frame: .zero, style: .plain)
        _tableView.rowHeight = 50.0
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.isScrollEnabled = false
        _tableView.separatorInset = .zero
        _tableView.separatorColor = .init(hex: "#F5F5F5")
        _tableView.register(DDSheetTableViewCell.self, forCellReuseIdentifier: DDSheetTableViewCell.reusedID)
        return _tableView
    }()
    
    /// CGFloat
    private var contentHeight: CGFloat {
        return 36.0 + CGFloat(items.count) * tableView.rowHeight + cornerRadius * 0.5
    }
    
    /// CGFloat
    private var perferWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return view.bounds.width
        } else {
            return max(min(UIScreen.current.bounds.width, UIScreen.current.bounds.height) * 0.7, 375.0)
        }
    }
    
    private let items: [DDSheetItem]
    
    private let handler: ((DDSheetItem) -> Void)
    
    internal init(items: [DDSheetItem], handler: @escaping (DDSheetItem) -> Void) {
        self.items = items
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

}

extension DDSheetViewController {
    private func initialize() {
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(36.0)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension DDSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// numberOfRowsInSection
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Int
    /// - Returns: Int
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    /// cellForRowAt
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    /// - Returns: UITableViewCell
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DDSheetTableViewCell.reusedID, for: indexPath) as! DDSheetTableViewCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    /// didSelectRowAt
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: IndexPath
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            guard let this = self else { return }
            this.handler(this.items[indexPath.row])
        }
    }
}

extension DDSheetViewController: PanModalPresentable {
    
    /// panScrollable
    internal var panScrollable: UIScrollView? {
        return tableView
    }
    
    /// longFormHeight
    internal var longFormHeight: PanModalHeight {
        return .contentHeight(contentHeight)
    }
    
    /// shortFormHeight
    internal var shortFormHeight: PanModalHeight {
        return .contentHeight(contentHeight)
    }
}
