import UIKit

final class GraphView: UIView {
    struct Part {
        let color: UIColor
        let value: CGFloat
    }
    
    enum Mode {
        case pie
        case donut(lineWidth: CGFloat)
    }
    
    var parts: [Part] = [] {
        didSet {
            setup()
            redrawAnimatableIfNeeded()
        }
    }
    var mode: Mode = .pie {
        didSet {
            redrawAnimatableIfNeeded()
        }
    }
    
    var initialAngle: CGFloat = 3 * .pi / 2 {
        didSet {
            redrawAnimatableIfNeeded()
        }
    }
    
    var animatable: Bool = true {
        didSet {
            redrawAnimatableIfNeeded()
        }
    }
    
    private var total: CGFloat {
        parts.reduce(.zero, { $0 + $1.value })
    }
    
    private var lineWidth: CGFloat {
        switch mode {
        case .pie:
            return min(bounds.midX, bounds.midY)
        case .donut(let lineWidth):
            return lineWidth
        }
    }
    
    private var radius: CGFloat {
        min(bounds.midX, bounds.midY) - (lineWidth / 2.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var sublayers: [CAShapeLayer] = []
    
    private func setup() {
        sublayers.forEach { $0.removeFromSuperlayer() }
        sublayers = {
            return parts.map {
                let shapeLayer = CAShapeLayer()
                shapeLayer.strokeColor = $0.color.cgColor
                shapeLayer.fillColor = UIColor.clear.cgColor
                return shapeLayer
            }
        }()
        sublayers.forEach { layer.addSublayer($0) }
    }
    
    private var isInitialDraw: Bool = true
    private func redrawAnimatableIfNeeded() {
        isInitialDraw = true
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard bounds != .zero else { return }
        
        _ = parts.enumerated().reduce(into: 0.0, { result, tuple in
            let startAngle = initialAngle + (result / total) * (2 * .pi)
            result += tuple.element.value
            let endAngle = initialAngle + (result / total) * (2 * .pi)
            
            let shapeLayer = sublayers[tuple.offset]
            shapeLayer.path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            ).cgPath
            
            shapeLayer.lineWidth = lineWidth
        })
        
        setupAnimationsIfNeeded()
    }
    
    private func setupAnimationsIfNeeded() {
        guard animatable, isInitialDraw else { return }
        isInitialDraw = false
        
        _ = sublayers.enumerated().reduce(into: 0.0) { result, tuple in
            let partAnimationDuration = parts[tuple.offset].value / total * 2.0
            let animation = makeAnimation(for: tuple.element, startTiming: result, duration: partAnimationDuration)
            result += partAnimationDuration
            tuple.element.add(animation, forKey: nil)
        }
    }
    
    private func makeAnimation(
        for layer: CAShapeLayer,
        startTiming: TimeInterval,
        duration: TimeInterval
    ) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.beginTime = CACurrentMediaTime() + startTiming
        animation.duration = duration
        animation.fillMode = .backwards
        animation.isRemovedOnCompletion = true
        return animation
    }
}
