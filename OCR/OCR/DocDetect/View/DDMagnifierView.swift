//
//  DDMagnifierView.swift
//  OCR
//
//  Created by dexiong on 2024/4/16.
//

import Foundation

class DDMagnifierView: UIWindow {
    
    //MARK: - 公有属性
    
    /// 旋转角度
    internal var originAngle: OriginAngle = .deg0
    
    /// adjustPoint
    internal var adjustPoint: CGPoint = .zero
    
    /// targetPoint
    internal var targetPoint: CGPoint = .zero {
        didSet {
            guard let target = target, let window = target.window else { return }
            let center: CGPoint = window.convert(targetPoint, from: target)
            self.center = .init(x: center.x + adjustPoint.x, y: center.y - bounds.height * 0.5 + adjustPoint.y)
            layer.setNeedsDisplay()
        }
    }
    
    /// outlineColor
    internal var outlineColor: UIColor = .lightGray {
        didSet {
            layer.borderColor = outlineColor.cgColor
            layer.setNeedsDisplay()
        }
    }
    
    /// outlineWidth
    internal var outlineWidth: CGFloat = 2 {
        didSet {
            layer.borderWidth = outlineWidth
            layer.setNeedsDisplay()
        }
    }
    
    //MARK: - 私有属性
    
    /// UIView
    private var target: UIView?
    
    /// scale
    private var scale: CGFloat = 2.0
    
    /// offset
    private var offset: CGPoint = .zero
    

    //MARK: - 生命周期
    
    /// init
    /// - Parameters:
    ///   - frame: CGRect 放大镜frame
    ///   - target: UIView 放大镜目标
    ///   - scale: CGFloat 放大倍数
    ///   - offset: CGPoint 偏移
    internal init(frame: CGRect, at target: UIView, scale: CGFloat = 2, offset: CGPoint = .zero) {
        super.init(frame: frame)
        if frame.size == .zero {
            self.frame.size = .init(width: 80.0, height: 80.0)
        }
        windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        layer.cornerRadius = self.frame.width * 0.5
        layer.masksToBounds = true
        backgroundColor = .clear
        layer.borderColor = outlineColor.cgColor
        layer.borderWidth = outlineWidth
        windowLevel = .alert
        self.scale = scale
        self.offset = offset
        self.target = target
        addAccurate()
    }
    
    /// init corder
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// draw
    /// - Parameters:
    ///   - layer: CALayer
    ///   - ctx: CGContext
    internal override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        //提前位移半个长宽
        ctx.translateBy(x: frame.width * 0.5, y: frame.height * 0.5);
        ctx.scaleBy(x: 1.5, y: 1.5)
        ctx.rotate(by: originAngle.counterclockwiseRotationAngle)
        //再次位移后就可以把触摸点移至self.center的位置
        ctx.translateBy(x: -1 * targetPoint.x, y: -1 * targetPoint.y)
        target?.layer.render(in: ctx)
    }
    
    /// “+”锚点
    private func addAccurate() {
        if let sublayers = layer.sublayers {
            for layer in sublayers {
                if layer is CAShapeLayer {
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        let lineLayer = CAShapeLayer()
        let plusShapePath = CGMutablePath()
        lineLayer.fillColor = UIColor.clear.cgColor//填充色
        lineLayer.strokeColor = UIColor.white.cgColor//线颜色
        lineLayer.lineWidth = 1
        plusShapePath.move(to: .init(x: center.x - 15.0, y: center.y))
        plusShapePath.addLine(to: .init(x: center.x + 15.0, y: center.y))
        plusShapePath.move(to: .init(x: center.x, y: center.y - 15.0))
        plusShapePath.addLine(to: .init(x: center.x, y: center.y + 15.0))
        lineLayer.path = plusShapePath
        layer.addSublayer(lineLayer)
    }
    
    deinit {
        print(#function, #file.hub.lastPathComponent)
    }
}
