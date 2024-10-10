//
//  MovingDot.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/18/24.
//

import UIKit

protocol MovingDotPrtc: MovingDot {
    func getDistance(from point: CGPoint) -> CGFloat
    func setPosition(_ point: CGPoint) -> CGPoint
    func xLockToggled() -> MovingDotPrtc
    func yLockToggled() -> MovingDotPrtc
    func set(layer: MovingDot)
}

class MovingDot: CAShapeLayer, MovingDotPrtc {
    
    var dx: Double = 0.0
    var dy: Double = 0.0
    var superBounds = CGRect()
    static let defaultPath = UIBezierPath(ovalIn: CGRect(x: -8, y: -8, width: 16, height: 16)).cgPath
    
    override init() {
        super.init()
        path = MovingDot.defaultPath
        actions = ["position": NSNull()]
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        guard let layer = layer as? MovingDot else { return }
        self.superBounds = layer.superBounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(layer: MovingDot) {
        self.path = layer.path
        self.fillColor = layer.fillColor
        self.position = layer.position
        self.actions = layer.actions
        self.zPosition = layer.zPosition
        self.superBounds = layer.superBounds
    }
    
    func getDistance(from point: CGPoint) -> CGFloat {
        dx = position.x - point.x
        dy = position.y - point.y
        
        return hypot(dx, dy)
    }
    
    func setPosition(_ point: CGPoint) -> CGPoint {
        let adjustedX = min(max(point.x + self.dx, self.superBounds.minX), self.superBounds.maxX)
        let adjustedY = min(max(point.y + self.dy, self.superBounds.minY), self.superBounds.maxY)
        position = CGPoint(x: adjustedX, y: adjustedY)
        return position
    }
    
    func xLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot_XLocked()
        dot.set(layer: self)
        return dot
    }
    func yLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot_YLocked()
        dot.set(layer: self)
        return dot
    }
    func resetLock() -> MovingDot {
        self.removeFromSuperlayer()
        let dot = MovingDot()
        dot.set(layer: self)
        return dot
    }
    func cleardXdY() {
        dx=0; dy=0
    }
}

class MovingDot_XLocked: MovingDot {
    
    override func setPosition(_ point: CGPoint) -> CGPoint {
         let adjustedY = min(max(point.y + dy, superBounds.minY), superBounds.maxY)
         position.y = adjustedY
        return position
    }
    
    override func xLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot()
        dot.set(layer: self)
        return dot
    }
    override func yLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = LockedDot()
        dot.set(layer: self)
        return dot
    }
}

class MovingDot_YLocked: MovingDot {
    override func setPosition(_ point: CGPoint) -> CGPoint {
         let adjustedX = min(max(point.x + dx, superBounds.minX), superBounds.maxX)

         position.x = adjustedX

        return position
    }
    override func xLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = LockedDot()
        dot.set(layer: self)
        return dot
    }
    override func yLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot()
        dot.set(layer: self)
        return dot
    }
}

class LockedDot: MovingDot {
    override func setPosition(_ point: CGPoint) -> CGPoint {
        return position
    }
    override func xLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot_YLocked()
        dot.set(layer: self)
        return dot
    }
    override func yLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot_XLocked()
        dot.set(layer: self)
        return dot
    }
}
