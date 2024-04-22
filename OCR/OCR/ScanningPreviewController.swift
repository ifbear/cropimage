//
//  ScanningPreviewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import UIKit

class ScanningPreviewController: UIViewController {

    
    /// titleLabel
    private lazy var titleLabel: UILabel = {
        let _label: UILabel = .init()
        _label.text = "点击图片进行调整"
        _label.font = .systemFont(ofSize: 17.0)
        _label.textColor = .white
        return _label
    }()
    
    /// collectionView
    private lazy var collectionView: UICollectionView = {
        let _layout: UICollectionViewFlowLayout = .init()
        _layout.scrollDirection = .horizontal
        _layout.minimumLineSpacing = 0.0
        _layout.minimumInteritemSpacing = 0.0
        let _view: UICollectionView = .init(frame: .zero, collectionViewLayout: _layout)
        _view.register(ScanningPreviewCell.self, forCellWithReuseIdentifier: "ScanningPreviewCell")
        _view.showsHorizontalScrollIndicator = false
        _view.backgroundColor = .clear
        _view.isPagingEnabled = true
        _view.delegate = self
        _view.dataSource = self
        return _view
    }()
    
    /// pagesLabel
    private lazy var pagesLabel: UILabel = {
        let _label: UILabel = .init()
        _label.text = "1/1"
        _label.font = .systemFont(ofSize: 17.0)
        _label.textColor = .white
        return _label
    }()
    
    /// bottomBar
    private lazy var bottomView: UIView = {
        let _view: UIView = .init()
        _view.backgroundColor = .init(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        return _view
    }()
    
    /// UIButton
    private lazy var cameraButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("拍照", for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// UIButton
    private lazy var sendButton: UIButton = {
        let _button: UIButton = .init(type: .custom)
        _button.setTitle("添加至邮件", for: .normal)
        _button.setTitleColor(.white, for: .normal)
        _button.addTarget(self, action: #selector(Self.buttonActionHandler(_:)), for: .touchUpInside)
        return _button
    }()
    
    //MARK: - 生命周期
    
    internal override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let buttonAppearance: UIBarButtonItemAppearance = .init(style: .plain)
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let appearance: UINavigationBarAppearance = .init()
        appearance.configureWithOpaqueBackground()
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
    }


}

extension ScanningPreviewController {
    
    /// initialize
    private func initialize() {
        view.backgroundColor = .black
        
        navigationItem.rightBarButtonItem = .init(title: "相册", style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
        navigationItem.leftBarButtonItem = .init(image: .init(named: "icns-back"), style: .plain, target: self, action: #selector(Self.itemActionHandler(_:)))
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24.0)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.center.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }
        
        view.addSubview(pagesLabel)
        pagesLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(24.0)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        bottomView.addSubview(cameraButton)
        cameraButton.snp.makeConstraints {
            $0.bottom.top.equalTo(bottomView.safeAreaLayoutGuide)
            $0.left.equalTo(bottomView.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(49.0)
        }
        
        bottomView.addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.bottom.top.equalTo(bottomView.safeAreaLayoutGuide)
            $0.right.equalTo(bottomView.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(49.0)
        }
        
    }
    
    /// buttonActionHandler
    /// - Parameter button: UIButton
    @objc private func buttonActionHandler(_ button: UIButton) {

    }
    
    /// itemActionHandler
    /// - Parameter item: UIBarButtonItem
    @objc private func itemActionHandler(_ item: UIBarButtonItem) {
        switch item {
        case navigationItem.rightBarButtonItem:
            break
        case navigationItem.leftBarButtonItem:
            navigationController?.popViewController(animated: true)
            
        default: break
        }
    }
}

extension ScanningPreviewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// sizeForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - indexPath: IndexPath
    /// - Returns: CGSize
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    
    /// scrollViewDidScroll
    /// - Parameter scrollView: UIScrollView
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let count = collectionView(collectionView, numberOfItemsInSection: 0)
        let index = min(Int(scrollView.contentOffset.x / collectionView.bounds.width + 0.5) + 1, count)
        self.pagesLabel.text = "\(index)/\(count)"
    }

    
    /// numberOfItemsInSection
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - section: Int
    /// - Returns: Int
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    /// cellForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: UICollectionViewCell
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScanningPreviewCell", for: indexPath) as! ScanningPreviewCell
        return cell
    }
    
    /// didSelectItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller: ScanningCropViewController = .init(image: .init(named: "")!)
        controller.retakeActionHandler = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        controller.reloadActionHandler = { [weak self] in
            self?.collectionView.reloadItems(at: [indexPath])
        }
        controller.modalPresentationStyle = .overFullScreen
//        let navi: UINavigationController = .init(rootViewController: controller)
//        navi.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
    
}
