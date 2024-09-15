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

class TouchMeView: UIView {
    
    weak var delegate: TouchMeViewDelegate?

    private var dots: [CAShapeLayer] = []
    private var allDots: [CAShapeLayer] = []
    
    private var activeDot: CAShapeLayer?
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
            let dot = CAShapeLayer()
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
        dots = Array(allDots[offset..<endIndex])
        allDots.forEach{ $0.opacity = 0.2 }
        dots.enumerated().forEach{ i, dot in
            dot.opacity = 1.0
        }
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
        let closestDotInfo = allDots.enumerated().compactMap{ (index, dot) -> (element: CAShapeLayer, offset: Int, distance: CGFloat)? in
            guard !dot.isHidden else {return nil}
            guard dots.contains(dot) else {return nil}
            let distance = hypot(dot.position.x - point.x, dot.position.y - point.y)
            if distance < greatestDistance {
                return (element: dot, offset: index, distance: distance)
            } else { return nil }
        }.min(by: { $0.distance < $1.distance})
        
        if let closestDotInfo = closestDotInfo{
            activeDot = closestDotInfo.element
            activeDotIndex = closestDotInfo.offset
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

