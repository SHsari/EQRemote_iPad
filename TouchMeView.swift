//
//  TouchMeView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import UIKit

protocol TouchMeViewDelegate: AnyObject {
    func touchesBegin(_ index: Int)
    func dotDidMove(_ index: Int, _ position: XYPosition)
    func touchesEnded(_ index: Int)
}

class MovingDot: CAShapeLayer {
    var index: Int
    
    init(index: Int) {
        self.index = index
        super.init()
    }
    
    override init(layer: Any) {
        guard let layer = layer as? MovingDot else {
            fatalError("init(layer:) called with non-MovingDot")
        }
        self.index = layer.index
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDotActive(_ isActive: Bool) {
        self.isHidden = !isActive
    }
    func setXYPosition(_ x: Double, _ y: Double) {
        self.position = getPositionFromNormValues(x, y)
    }
    
    func setOpacity(value: Float) {
        self.opacity = value
    }
    func getDistance(from point: CGPoint) -> CGFloat {
        return hypot(position.x - point.x, position.y - point.y)
    }
    private func getPositionFromNormValues(_ x: Double, _ y: Double) -> CGPoint {
        var point = CGPoint()
        point.x = x * bounds.width
        point.y = (1 - y) * bounds.height
        return point
    }
}

class TouchMeView: UIView {
    
    weak var delegate: TouchMeViewDelegate?

    private var dots: [MovingDot] = []
    private var allDots: [MovingDot] = []
    
    private var activeDot: MovingDot?
    private var activeDotIndex: Int?
    private var initialTouchPoint: CGPoint?
    private var initialDotPoint: CGPoint?
    private let greatestDistance = CGFloat(150)

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }

    func initializeDots() {
        for (i, position) in factoryPosition.enumerated() {
            let dot = MovingDot(index: i)
            dot.fillColor = colorDict[i].cgColor
            dot.path = UIBezierPath(ovalIn: CGRect(x: -8, y: -8, width: 16, height: 16)).cgPath
            dot.position = getPositionFromNormValues(position)
            dot.actions = ["position": NSNull()]
            
            allDots.append(dot)
            layer.addSublayer(dot)
        }
    }

    func setSectionActive(_ section: Int) {
        let offset = section*sectionSize
        let endIndex = offset + sectionSize
        allDots.forEach{ $0.setOpacity(value: 0.2) }
        dots = Array(allDots[offset..<endIndex])
        dots.forEach{ $0.setOpacity(value: 1.0) }
    }

    func setDotActive(_ index: Int, isActive: Bool) {
        allDots[index].isHidden = !isActive
    }

    func setDotByPreset(index: Int, value: XYPosition) {
        allDots[index].position = getPositionFromNormValues(value)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            initialTouchPoint = touch.location(in: self)
            setClosestDot()
            guard let dotIndex = activeDotIndex else {return}
            delegate?.touchesBegin(dotIndex)
            initialDotPoint = activeDot?.position
        }
    }
    
    private func setClosestDot() {
        // 가장 가까운 도트 찾기
        guard let point = initialTouchPoint else { return }
        let closestDotInfo = dots.enumerated().compactMap{ (_ , dot) -> (element: MovingDot, index: Int, distance: CGFloat)? in
            guard !dot.isHidden else {return nil}
            let distance = dot.getDistance(from: point)
            if distance < greatestDistance {
                return (element: dot, index: dot.index, distance: distance)
            } else { return nil }
        }.min(by: { $0.distance < $1.distance})
        
        if let closestDotInfo = closestDotInfo{
            activeDot = closestDotInfo.element
            activeDotIndex = closestDotInfo.index
        } else {
            activeDot = nil
            activeDotIndex = nil
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              self.bounds.contains(touch.location(in: self)),
              let initialTouch = initialTouchPoint,
              let initialDotPoint = initialDotPoint,
              let activeDot = activeDot,
              let index = activeDotIndex else { return }
        let location = touch.location(in: self)
        let deltaX = location.x - initialTouch.x
        let deltaY = location.y - initialTouch.y
        
        //CATransaction.begin()
        //CATransaction.setDisableActions(true)
        activeDot.position = CGPoint(x: initialDotPoint.x + deltaX, y: initialDotPoint.y + deltaY)
        //CATransaction.commit()
        delegate?.dotDidMove(index, getNormValues(activeDot.position))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let index = activeDotIndex else { return }
        delegate?.touchesEnded(index)
    }
    
    private func getNormValues(_ point: CGPoint) -> XYPosition {
        let normX = point.x/bounds.width
        let normY = 1 - (point.y/bounds.height)
        return XYPosition(x: normX, y: normY)
    }
    
    private func getPositionFromNormValues(_ normP: XYPosition) -> CGPoint {
        var point = CGPoint()
        point.x = normP.x * bounds.width
        point.y = (1 - normP.y) * bounds.height
        return point
    }
}

