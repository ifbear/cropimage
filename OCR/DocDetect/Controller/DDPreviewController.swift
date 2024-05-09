//
//  DDPreviewController.swift
//  OCR
//
//  Created by dexiong on 2024/4/19.
//

import UIKit

class DDPreviewController: UIViewController {
    
    /// ([URL]) -> Void
    internal var complateBlock: (([URL]) -> Void)? = nil
    
    /// titleLabel
    private lazy var titleLabel: UILabel = {
        let _label: UILabel = .init()
        _label.text = "点击图片进行调整"
        _label.font = .pingfang(ofSize: 17.0)
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
        _view.register(DDPreviewCell.self, forCellWithReuseIdentifier: DDPreviewCell.reusedID)
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
        _label.text = "1/\(cropModels.count)"
        _label.font = .pingfang(ofSize: 17.0)
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
    
    /// cropModels
    private var cropModels: [DDCropModel] {
        get { (navigationController as! DDNavigationController).cropModels }
        set { (navigationController as! DDNavigationController).cropModels = newValue }
    }
    
    //MARK: - 生命周期
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}

extension DDPreviewController {
    
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
        switch button {
        case cameraButton:
            navigationController?.popViewController(animated: true)
            
        case sendButton:
            let items: [DDSheetItem] = [.image, .pdf, .word, .ppt, .excel]
            let controller: DDSheetViewController = .init(items: items) { [unowned self] item in
                switch item.tag {
                case DDSheetItem.image.tag:
                    convertImage()
                    
                case DDSheetItem.pdf.tag:
                    convertPDF()
                    
                case DDSheetItem.word.tag:
                    break
                case DDSheetItem.ppt.tag:
                    break
                case DDSheetItem.excel.tag:
                    break
                default: break
                }
            }
            presentPanModal(controller)
            
        default: break
        }
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
    
    /// 转图片
    private func convertImage() {
        var urls: [URL] = []
        let tempUrl = FileManager.default.temporaryDirectory
        for model in cropModels {
            let url = tempUrl.hub.appending(pathComponent: "IMG_\(urls.count + 1).jpg", directoryHint: .notDirectory)
            try? FileManager.default.removeItem(at: url)
            guard let image = model.cropImage else { continue }
            do {
                try image.jpegData(compressionQuality: 0.75)?.write(to: url)
                guard FileManager.default.fileExists(atPath: url.path) else { continue }
                urls.append(url)
            } catch {
                print(error)
            }
        }
        guard urls.isEmpty == false else { return }
        dismiss(animated: true) { [weak self] in
            guard let this = self else { return }
            this.complateBlock?(urls)
        }
    }
    
    /// 转PDF
    private func convertPDF() {
        do {
            let pdfContext = UIGraphicsPDFRenderer(bounds: view.bounds, format: .init())
            let outputFile = FileManager.default.temporaryDirectory.appendingPathComponent("temp.pdf")
            try? FileManager.default.removeItem(at: outputFile)
            var prev: CGFloat?
            try pdfContext.writePDF(to: outputFile) { context in
                let pdfW = context.pdfContextBounds.width
                let pdfH = context.pdfContextBounds.height
                cropModels.forEach { model in
                    let image = model.cropImage ?? model.image
                    let ratio = image.size.width < pdfW ? (image.size.height < pdfH ? 1.0 : pdfH / image.size.height) : pdfW / image.size.width
                    let w = image.size.width * ratio
                    let h = image.size.height * ratio
                    let y: CGFloat
                    if let prev = prev, prev + h < pdfH {
                        y = prev
                    } else {
                        context.beginPage()
                        y = 0
                    }
                    image.draw(in: CGRect(x: (pdfW - w) * 0.5, y: y, width: w, height: h))
                    prev = h
                }
            }
            let quickLook: DDQuickLookViewController = .init(items: [.init(file: outputFile, name: outputFile.lastPathComponent)]) { [weak self] finish in
                guard let this = self, finish == true else { return }
                // 添加邮件操作
                this.dismiss(animated: true) { [weak this] in
                    guard let this = this else { return }
                    this.complateBlock?([outputFile])
                }
            }
            let navi: UINavigationController = .init(rootViewController: quickLook)
            navi.modalPresentationStyle = .fullScreen
            self.present(navi, animated: true)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension DDPreviewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        return cropModels.count
    }
    
    /// cellForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: UICollectionViewCell
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DDPreviewCell.reusedID, for: indexPath) as! DDPreviewCell
        cell.cropModel = cropModels[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    /// didSelectItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cropModels[indexPath.item]
        let controller: DDCropViewController = .init(cropModel: model)
        controller.retakeActionHandler = { [weak self] in
            self?.cropModels.remove(at: indexPath.item)
            self?.navigationController?.popViewController(animated: true)
        }
        controller.reloadActionHandler = { [weak self] in
            self?.collectionView.reloadItems(at: [indexPath])
        }
        let navi: UINavigationController = .init(rootViewController: controller)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }
    
}

//MARK: - DDPreviewCellDelegate
extension DDPreviewController: DDPreviewCellDelegate {
    
    /// delete
    /// - Parameters:
    ///   - cell: ScanningPreviewCell
    ///   - model: DDCropModel
    internal func cell(_ cell: DDPreviewCell, delete model: DDCropModel) {
        guard let index = cropModels.firstIndex(where: { $0 == model }) else { return }
        cropModels.remove(at: index)
        collectionView.deleteItems(at: [.init(row: index, section: 0)])
        if index == cropModels.count {
            pagesLabel.text = "\(index)/\(cropModels.count)"
        } else if index < cropModels.count {
            pagesLabel.text = "\(index + 1)/\(cropModels.count)"
        }
        if cropModels.isEmpty {
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// ocr
    /// - Parameters:
    ///   - cell: ScanningPreviewCell
    ///   - model: DDCropModel
    internal func cell(_ cell: DDPreviewCell, ocr model: DDCropModel) {
        let controller: DDTextSelectionViewController = .init()
        presentPanModal(controller)
    }
}
