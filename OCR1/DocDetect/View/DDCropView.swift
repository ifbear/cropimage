//
//  DDCropView.swift
//  OCR
//
//  Created by dexiong on 2024/4/15.
//

import Foundation
import UIKit


enum NearstPosition: Int {
    case none = -1, topLeft = 0, topRight, bottomLeft, bottomRight
}

// DDCropViewDelegate
protocol DDCropViewDelegate: NSObjectProtocol {
    func cropBegin(at point: CGPoint)
    func cropMoved(at point: CGPoint)
    func cropEnded(at potin: CGPoint)
}

class DDCropView: UIView {
    //MARK: - 公有属性
    
    /// DSCropViewDelegate
    internal weak var delegate: DDCropViewDelegate? = nil
    
    /// 线宽
    internal var lineWidth: CGFloat = 2.0
    
    /// 线颜色
    internal var lineColor: UIColor = .init(red: 61.0 / 255.0, green: 105.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)
    
    /// 最大显示区域
    internal var maxResizeFrame: CGRect = .zero
    
    /// position
    internal var position: Rectangle = .default {
        didSet {
            setNeedsLayout()
            layer.setNeedsDisplay()
        }
    }
    
    //MARK: - 私有属性
    
    /// CAShapeLayer 阴影
    private lazy var shadeLayer: CAShapeLayer = {
        let layer: CAShapeLayer = .init()
        layer.frame = bounds
        layer.fillColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillRule = .evenOdd // 填充规则
        return layer
    }()
    
    /// 偏移向量
    private var transformVector: CGVector = .zero
    
    /// 移动点
    private var nearstPosition: NearstPosition = .none
    
    /// UIImage
    private let image: UIImage
    
    //MARK: - 生命周期
    
    /// init
    /// - Parameters:
    ///   - frame: CGRect
    ///   - image: UIImage
    internal init(frame: CGRect, image: UIImage) {
        self.image = image
        super.init(frame: frame)
        
        initialize()
    }
    
    /// init coder
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}

extension DDCropView {
    
    /// initialize
    private func initialize() {
        backgroundColor = .clear

        layer.addSublayer(shadeLayer)
    }
}

extension DDCropView {
    
    /// adjustPosition
    internal func adjustPosition() {
        let scale = bounds.height / maxResizeFrame.height
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let topLeft: CGPoint = position.topLeft.applying(transform)
        let topRight: CGPoint = position.topRight.applying(transform)
        let bottomLeft: CGPoint = position.bottomLeft.applying(transform)
        let bottomRight: CGPoint = position.bottomRight.applying(transform)
        position = .init(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        maxResizeFrame = bounds
    }
    
    /// touchesBegan
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent?
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        //计算最相近的点, 直线距离
        let points = [position.topLeft, position.topRight, position.bottomLeft, position.bottomRight]
        var nearst = CGFloat.greatestFiniteMagnitude
        var index = 0
        var transformVector: CGVector = .zero
        var nearstPoint: CGPoint = .zero
        for point in points {
            let distance = point.distance(location)
            if distance <= nearst {
                nearst = distance
                index = points.firstIndex(of: point) ?? 0
                transformVector = .init(dx: location.x - point.x, dy: location.y - point.y)
                nearstPoint = point
            }
        }
        self.transformVector = transformVector
        self.nearstPosition = .init(rawValue: index) ?? .none
        delegate?.cropBegin(at: nearstPoint)
    }
    
    /// touchesMoved
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent?
    internal override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let point: CGPoint = .init(x: location.x - transformVector.dx, y: location.y - transformVector.dy)
        switch nearstPosition {
        case .none: break
        case .topLeft:
            position.topLeft = .init(x: min(max(point.x, 0.0), bounds.width), y: min(max(point.y, 0), bounds.height))
            delegate?.cropMoved(at: position.topLeft)
            
        case .topRight:
            position.topRight = .init(x: min(max(point.x, 0.0), bounds.width), y: min(max(point.y, 0), bounds.height))
            delegate?.cropMoved(at: position.topRight)
            
        case .bottomLeft:
            position.bottomLeft = .init(x: min(max(point.x, 0), bounds.width), y: min(max(point.y, 0), bounds.height))
            delegate?.cropMoved(at: position.bottomLeft)
            
        case .bottomRight:
            position.bottomRight = .init(x: min(max(point.x, 0), bounds.width), y: min(max(point.y, 0), bounds.height))
            delegate?.cropMoved(at: position.bottomRight)
            
        }
        setNeedsDisplay()
    }
    
    /// touchesEnded
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent?
    internal override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        nearstPosition = .none
        transformVector = .zero
        setNeedsDisplay()
        delegate?.cropEnded(at: location)
    }
    
    /// draw
    /// - Parameter rect: CGRect
    internal override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 绘制不规则矩形
        let iregularPath: UIBezierPath = .init()
        iregularPath.move(to: position.topLeft)
        iregularPath.addLine(to: position.topRight)
        iregularPath.addLine(to: position.bottomRight)
        iregularPath.addLine(to: position.bottomLeft)
        iregularPath.close()
        
        //绘制遮罩和边缘识别路径
        let rectPath: UIBezierPath = .init(rect: rect)
        // 将不规则路径添加到矩形路径中，形成一个复合路径
        rectPath.append(iregularPath)
        // 组合好的路径设置为图层的路径
        shadeLayer.path = rectPath.cgPath
        
        // 绘制矩形
        if position.checkValid() {
            lineColor.set()
        } else {
            UIColor.red.set()
        }
        let rectangle: UIBezierPath = .init()
        rectangle.move(to: position.topLeft)
        rectangle.addLine(to: position.topRight)
        rectangle.addLine(to: position.bottomRight)
        rectangle.addLine(to: position.bottomLeft)
        rectangle.close()
        rectangle.stroke()
        
        // 画四角的圆
        let topLeftPath = UIBezierPath.init(arcCenter: position.topLeft, radius: 6.0, startAngle: 0.0, endAngle: 360.0, clockwise: true)
        topLeftPath.fill()
        
        let topRightPath = UIBezierPath.init(arcCenter: position.topRight, radius: 6.0, startAngle: 0.0, endAngle: 360.0, clockwise: true)
        topRightPath.fill()
        
        let bottomLeftPath = UIBezierPath.init(arcCenter: position.bottomLeft, radius: 6.0, startAngle: 0.0, endAngle: 360.0, clockwise: true)
        bottomLeftPath.fill()
        
        let bottomRightPath = UIBezierPath.init(arcCenter: position.bottomRight, radius: 6.0, startAngle: 0.0, endAngle: 360.0, clockwise: true)
        bottomRightPath.fill()
        
    }

}
