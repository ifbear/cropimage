//
//  DDPannelController.swift
//  OCR
//
//  Created by dexiong on 2024/4/24.
//

import UIKit
import PanModal


extension DDPannelController {
    private enum SlideSelectType {
        case none
        case select
        case cancel
    }
    private enum AutoScrollDirection {
        case none
        case top
        case bottom
    }
}

class DDPannelController: UIViewController {
    
    /// topView
    private lazy var topView: UIView = {
        let _line: UIView = .init()
        _line.backgroundColor = .init(hex: "#F5F5F5")
        let _view: UIView = .init()
        _view.addSubview(_line)
        _line.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(1.0)
        }
        return _view
    }()
    
    /// cancelButton
    private lazy var cancelButton: UIButton = {
        let _button: UIButton = .init()
        _button.setTitle("取消", for: .normal)
        _button.setTitleColor(.black, for: .normal)
        _button.titleLabel?.font = .pingfang(ofSize: 16.0)
        _button.addTarget(self, action: #selector(Self.controlActionHander(_:)), for: .touchUpInside)
        return _button
    }()
    
    /// titleLabel
    private lazy var titleLabel: UILabel = {
        let _label: UILabel = .init()
        _label.text = "在文字上滑动选择"
        _label.font = .pingfang(ofSize: 17.0)
        return _label
    }()
    
    /// collectionView
    private lazy var collectionView: UICollectionView = {
        let _layout: UICollectionViewAlignedFlowLayout = .init(horizontalAlignment: .left, verticalAlignment: .top)
        _layout.minimumLineSpacing = 8.0
        _layout.minimumInteritemSpacing = 8.0
        _layout.sectionInset = .init(top: 36.0, left: 36.0, bottom: 36.0, right: 36.0)
        let _view: UICollectionView = .init(frame: .zero, collectionViewLayout: _layout)
        _view.register(DDPannelCell.self, forCellWithReuseIdentifier: "ScanningOCRTextCell")
        _view.allowsMultipleSelection = true
        _view.delegate = self
        _view.dataSource = self
        return _view
    }()
    
    /// bottomView
    private lazy var bottomView: UIStackView = {
        let _view: UIStackView = .init()
        _view.axis = .horizontal
        _view.distribution = .fillEqually
        _view.alignment = .fill
        _view.addArrangedSubview(selectItem)
        _view.addArrangedSubview(copyItem)
        _view.addArrangedSubview(translateItem)
        _view.addArrangedSubview(mailItem)
        return _view
    }()
    
    /// selectItem
    private lazy var selectItem: DDControlItem = {
        let _item: DDControlItem = .init()
        _item.image = .init(named: "icns-multiple-selection")
        _item.text = "多选"
        _item.addTarget(self, action: #selector(Self.controlActionHander(_:)), for: .touchUpInside)
        return _item
    }()
    
    /// copyItem
    private lazy var copyItem: DDControlItem = {
        let _item: DDControlItem = .init()
        _item.image = .init(named: "icns-copy")
        _item.text = "拷贝"
        _item.isEnabled = false
        _item.addTarget(self, action: #selector(Self.controlActionHander(_:)), for: .touchUpInside)
        return _item
    }()
    
    /// translateItem
    private lazy var translateItem: DDControlItem = {
        let _item: DDControlItem = .init()
        _item.image = .init(named: "icns-translate")
        _item.text = "翻译"
        _item.isEnabled = false
        _item.addTarget(self, action: #selector(Self.controlActionHander(_:)), for: .touchUpInside)
        return _item
    }()
    
    /// mailItem
    private lazy var mailItem: DDControlItem = {
        let _item: DDControlItem = .init()
        _item.image = .init(named: "icns-mail")
        _item.text = "发送邮件"
        _item.isEnabled = false
        _item.addTarget(self, action: #selector(Self.controlActionHander(_:)), for: .touchUpInside)
        return _item
    }()
    
    /// panGesture
    private lazy var panGesture: UIPanGestureRecognizer = {
        let _pan: UIPanGestureRecognizer = .init(target: self, action: #selector(Self.gestureRecognizerHandler(_:)))
        _pan.delegate = self
        return _pan
    }()
    
    /// dataList
    private lazy var dataList: [DDOcrModel] = []
        
    /// 滑动选择 或 取消
    /// 当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
    private var panSelectType: SlideSelectType = .none
    
    /// 是否开始出发滑动选择 滑动点能获取到cell 表示触发滑动选择
    private var beginPanSelection = false
    
    /// 开始滑动的indexPath
    private var beginSlideIndexPath: IndexPath?
    
    /// 最后滑动经过的index，开始的indexPath不计入
    private var lastSlideIndexPath: IndexPath?
    
    /// CADisplayLink
    private var autoScrollTimer: CADisplayLink?
    
    /// autoScrollInfo
    private var autoScrollInfo: (direction: AutoScrollDirection, speed: CGFloat) = (.none, 0)
    
    /// lastPanUpdateTime
    private var lastPanUpdateTime = CACurrentMediaTime()

    //MARK: - 生命周期
    
    /// viewDidLoad
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
        for i in 0...100 {
            let model: DDOcrModel = .init()
            model.text = "cell: \(i)"
            dataList.append(model)
        }
        
        collectionView.reloadData()
    }

    deinit {
        print(#function, #file.hub.lastPathComponent)
    }

}

extension DDPannelController {
    
    /// initialize
    private func initialize() {
        view.backgroundColor = .white
        view.addGestureRecognizer(panGesture)
        
        view.addSubview(topView)
        topView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(52.0)
        }
        
        topView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(14.0)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(40.0)
        }
        
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(75.0)
        }
    }
    
    /// controlActionHander
    /// - Parameter control: UIControl
    @objc private func controlActionHander(_ control: UIControl) {
        switch control {
        case selectItem:
            dataList.forEach { model in
                model.isSelected = true
            }
            collectionView.reloadData()
            copyItem.isEnabled = true
            translateItem.isEnabled = true
            mailItem.isEnabled = true
            
        case copyItem:
            let text = dataList.compactMap { $0.isSelected ? $0.text : nil }.joined(separator: "")
            UIPasteboard.general.string = text
            
        case translateItem:
            break
            
        case mailItem:
            break
            
        case cancelButton:
            dismiss(animated: true)
            
        default: break
        }
    }
}

extension DDPannelController {
    
    /// refreshBottomView
    private func refreshBottomView() {
        let isEnabled = dataList.filter({ $0.isSelected == true }).isEmpty == false
        copyItem.isEnabled = isEnabled
        mailItem.isEnabled = isEnabled
        translateItem.isEnabled = isEnabled
    }
    
    /// autoScrollWhenSlideSelect
    /// - Parameter pan: UIPanGestureRecognizer
    private func autoScrollWhenSlideSelect(_ pan: UIPanGestureRecognizer) {
        let top = topView.frame.maxY + 30.0
        let bottom = bottomView.frame.minY - 30.0
        let point = pan.location(in: view)
        var diff: CGFloat = 0
        var direction: AutoScrollDirection = .none
        if point.y < top {
            diff = top - point.y
            direction = .top
        } else if point.y > bottom {
            diff = point.y - bottom
            direction = .bottom
        } else {
            stopAutoScroll()
            return
        }
        let s = min(diff, 60) / 60 * 600
        
        autoScrollInfo = (direction, s)
        
        if autoScrollTimer == nil {
            cleanTimer()
            autoScrollTimer = CADisplayLink(target: WeakProxy(self), selector: #selector(autoScrollAction))
            autoScrollTimer?.add(to: RunLoop.current, forMode: .common)
        }
    }
    
    /// cleanTimer
    private func cleanTimer() {
        autoScrollTimer?.remove(from: RunLoop.current, forMode: .common)
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    /// stopAutoScroll
    private func stopAutoScroll() {
        autoScrollInfo = (.none, 0)
        cleanTimer()
    }
    
    /// autoScrollAction 定时器任务
    @objc private func autoScrollAction() {
        guard autoScrollInfo.direction != .none, panGesture.state != .possible else {
            stopAutoScroll()
            return
        }
        let duration = CGFloat(autoScrollTimer?.duration ?? 1 / 60)
        if CACurrentMediaTime() - lastPanUpdateTime > 0.2 {
            // Finger may be not moved in slide selection mode
            gestureRecognizerHandler(panGesture)
        }
        let distance = autoScrollInfo.speed * duration
        let offset = collectionView.contentOffset
        let inset = collectionView.contentInset
        if autoScrollInfo.direction == .top, offset.y + inset.top > distance {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y - distance)
        } else if autoScrollInfo.direction == .bottom, offset.y + collectionView.bounds.height + distance - inset.bottom < collectionView.contentSize.height {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y + distance)
        }
    }
    
    /// 触发手势
    /// - Parameter gesture: UIPanGestureRecognizer
    @objc private func gestureRecognizerHandler(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        let cell = collectionView.cellForItem(at: indexPath)
        
        switch gesture.state {
        case .began:
            beginPanSelection = cell != nil
            if beginPanSelection {
                beginSlideIndexPath = indexPath
                let model = dataList[indexPath.row]
                panSelectType = model.isSelected ? .cancel : .select
                model.isSelected = !model.isSelected
                if model.isSelected {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                } else {
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
                lastSlideIndexPath = indexPath
            }
            
        case .changed:
            if beginPanSelection == false || indexPath == lastSlideIndexPath || cell == nil { return }
            autoScrollWhenSlideSelect(gesture)
            guard let beginIndexPath = beginSlideIndexPath else { return }
            lastPanUpdateTime = CACurrentMediaTime()
            lastSlideIndexPath = indexPath
            let minIndex = min(indexPath.row, beginIndexPath.row)
            let maxIndex = max(indexPath.row, beginIndexPath.row)
            let minIsBegin = minIndex == beginIndexPath.row
            var isSelectedChanged: Bool = false
            var i = beginIndexPath.row
            while minIsBegin ? i <= maxIndex : i >= minIndex {
                if i != beginIndexPath.row {
                    let p: IndexPath = .init(row: i, section: 0)
                    let m = dataList[i]
                    if panSelectType == .cancel, m.isSelected == true {
                        m.isSelected = false
                        collectionView.deselectItem(at: p, animated: false)
                        isSelectedChanged = true
                    } else if panSelectType == .select, m.isSelected == false {
                        m.isSelected = true
                        collectionView.selectItem(at: p, animated: false, scrollPosition: [])
                        isSelectedChanged = true
                    }
                }
                i += (minIsBegin ? 1 : -1)
            }
            if isSelectedChanged {
                refreshBottomView()
            }
            
        case .cancelled, .ended:
            beginPanSelection = false
            stopAutoScroll()
            panSelectType = .none
            
        default: break
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension DDPannelController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /// numberOfItemsInSection
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - section: Int
    /// - Returns: Int
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    /// cellForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: UICollectionViewCell
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScanningOCRTextCell", for: indexPath) as! DDPannelCell
        cell.model = dataList[indexPath.item]
        return cell
    }
    
    /// willDisplay
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - cell: UICollectionViewCell
    ///   - indexPath: IndexPath
    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
        cell.isSelected = model.isSelected
    }
    
    /// sizeForItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - collectionViewLayout: UICollectionViewLayout
    ///   - indexPath: IndexPath
    /// - Returns: CGSize
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = dataList[indexPath.item]
        if model.size != .zero {
            return model.size
        } else {
            let size = (model.text as NSString).boundingRect(with: .init(width: collectionView.bounds.width - 100.0, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], attributes: [.font: UIFont.systemFont(ofSize: 17.0)], context: nil).size
            model.size = .init(width: size.width + 25.0, height: max(size.height + 10.0, 32.0))
            return model.size
        }
    }
    
    /// didSelectItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataList[indexPath.item]
        model.isSelected = true
        refreshBottomView()
    }
    
    /// didDeselectItemAt
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    internal func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let model = dataList[indexPath.item]
        model.isSelected = false
        refreshBottomView()
    }
}

//MARK: - UIGestureRecognizerDelegate
extension DDPannelController: UIGestureRecognizerDelegate {
    
    /// gestureRecognizerShouldBegin
    /// - Parameter gestureRecognizer: UIGestureRecognizer
    /// - Returns: Bool
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        if topView.frame.contains(point) || bottomView.frame.contains(point) {
            return false
        }
        
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)
        if collectionView.indexPathForItem(at: pointInCollectionView) == nil {
            return false
        }
        
        return true
    }
}

//MARK: - PanModalPresentable
extension DDPannelController: PanModalPresentable {
    internal var panScrollable: UIScrollView? {
        return nil
    }
    
    internal var shortFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height * 0.6)
    }
    
    internal var longFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height * 0.6)
    }
    
    internal var allowsDragToDismiss: Bool {
        return false
    }

}
