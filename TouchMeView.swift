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
    func didDoubleTap(at index: Int)
    func pasteResquest(at index: Int)
}

class TouchMeView: UIView {
    
    weak var delegate: TouchMeViewDelegate?

    private var dots: [MovingDotPrtc] = []
    private var allDots: [MovingDotPrtc] = []
    private var dx: Double?
    private var dy: Double?
    
    private var activeDot: MovingDotPrtc?
    private var activeDotIndex: Int?
    private let greatestDistance = CGFloat(150)
    private var offset: Int = 0

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }

    func initialize(normPositions: [XYZPosition]) {
        setupDoubleTap()
        let xyPositions = normPositions.map { $0.getXY() }
        for (i, position) in xyPositions.enumerated() {
            let dot = MovingDot()
            dot.fillColor = colorDict[i].cgColor
            dot.superBounds = self.bounds
            dot.position = getPositionFromNormValues(position)
            dot.zPosition = CGFloat( i % sectionSize )
            allDots.append(dot)
            layer.addSublayer(dot)
        }
        setSectionActive(0)
    }
    func setupDoubleTap() {
        let doubleTapRECG = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRECG.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapRECG)
    }

    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: self)
        setClosestDot(touchPoint)
        dots.forEach{ $0.cleardXdY() }
        guard let dotIndex = activeDotIndex else {return}
        delegate?.didDoubleTap(at: dotIndex)
        bringActiveLayerFront()
        let position = factoryPreset_().bands[dotIndex].getXY()
        let point = activeDot!.setPosition(getPositionFromBindValues(position))
        delegate?.touchesMoved(getNormValues(point))
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
        let closestDotInfo = dots.enumerated().compactMap{ (index , dot) -> (element: MovingDotPrtc, index: Int, distance: CGFloat)? in
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
        delegate?.touchesMoved(getBindValues(position))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded()
        dots.forEach{$0.cleardXdY()}
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
    
    private func getPositionFromBindValues(_ bindP: XYPosition) -> CGPoint {
        var point = CGPoint()
        point.x = Calculate.normX(bindP.x) * bounds.width
        point.y = Calculate.normYwith(gain: bindP.y) * bounds.height
        return point
    }
    
    private func getBindValues(_ point: CGPoint) -> XYPosition {
        let freq = Calculate.frequency(point.x/bounds.width)
        let gain = Calculate.gain(point.y/bounds.height)
        return XYPosition(x: freq, y: gain)
    }
}

extension TouchMeView {
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
    
    func xLockToggled(at index: Int) {
        let dot = allDots[index].xLockToggled()
        dot.removeFromSuperlayer()
        layer.addSublayer(dot)
        allDots[index] = dot
        dots[index-offset] = dot
    }
    
    func yLockToggled(at index: Int) {
        let dot = allDots[index].yLockToggled()
        dot.removeFromSuperlayer()
        layer.addSublayer(dot)
        allDots[index] = dot
        dots[index-offset] = dot
    }

    func setPositionByPreset(at index: Int, with position: XYPosition) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        allDots[index].position = getPositionFromNormValues(position)
    }
    
    func setXwith(value: Double, at index: Int) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        activeDot?.position.x = value * bounds.width
    }
    func setYwith(value: Double, at index: Int) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        activeDot?.position.y = (1 - value) * bounds.height
    }
    
    func doubleTapped(at index: Int, with position: XYPosition) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        let newPosition = allDots[index].setPosition(getPositionFromNormValues(position))
        delegate?.touchesMoved(getNormValues(newPosition))
    }
}
