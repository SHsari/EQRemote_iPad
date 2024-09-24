//
//  TouchMeView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import UIKit

protocol TouchMeViewDelegate: AnyObject {
    func touchesBegan(_ index: Int)
    func touchesMoved(_ position: XYPosition)
    func touchesEnded()
}

class TouchMeView: UIView {
    
    weak var delegate: TouchMeViewDelegate?

    private var dots: [MovingDot] = []
    private var allDots: [MovingDot] = []
    private var dx: Double?
    private var dy: Double?
    
    private var activeDot: MovingDot?
    private var activeDotIndex: Int?
    private let greatestDistance = CGFloat(150)
    private var offset: Int = 0

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }

    func initialize() {
        let xyPositions = factoryPreset_().bands.map { $0.getXY() }
        for (i, position) in xyPositions.enumerated() {
            let dot = MovingDot()
            dot.fillColor = colorDict[i].cgColor
            dot.path = UIBezierPath(ovalIn: CGRect(x: -8, y: -8, width: 16, height: 16)).cgPath
            dot.position = getPositionFromNormValues(position)
            dot.actions = ["position": NSNull()]
            dot.zPosition = CGFloat( i % sectionSize )
            allDots.append(dot)
            layer.addSublayer(dot)
        }
        setSectionActive(0)
    }

    func setSectionActive(_ section: Int) {
        for (i, dot) in allDots.enumerated() {
            dot.opacity = 0.2; dot.zPosition = CGFloat(i % 4)
        }
        self.offset = section*sectionSize
        dots = Array(allDots[offset..<offset+sectionSize])
        dots.forEach{ $0.opacity = 1.0; $0.zPosition += 10 }
    }

    func setDotActive(_ index: Int, isActive: Bool) {
        allDots[index].isHidden = !isActive
    }

    func setDotByPreset(index: Int, value: XYPosition) {
        allDots[index].position = getPositionFromNormValues(value)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            setClosestDot(touch.location(in: self))
            guard let dotIndex = activeDotIndex else {return}
            delegate?.touchesBegan(dotIndex)
            bringActiveLayerFront()
        }
    }
    
    private func setClosestDot(_ initPoint: CGPoint) {
        // 가장 가까운 도트 찾기
        let closestDotInfo = dots.enumerated().compactMap{ (index , dot) -> (element: MovingDot, index: Int, distance: CGFloat)? in
            guard !dot.isHidden else {return nil}
            let distance = dot.getDistance(from: initPoint)
            if distance < greatestDistance {
                return (element: dot, index: index+offset, distance: distance)
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

    private func bringActiveLayerFront() {
        let indexedZ = activeDot!.zPosition
        for dot in dots {
            if dot.zPosition > indexedZ {
                dot.zPosition -= 1
            }
        }
        activeDot!.zPosition = 13
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              self.bounds.contains(touch.location(in: self)),
              let activeDot = activeDot else { return }
        let location = touch.location(in: self)
        let position = activeDot.setPosition(location)
        delegate?.touchesMoved(getNormValues(position))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded()
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
