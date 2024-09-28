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
    
    func set(layer: MovingDot) {
        self.path = layer.path
        self.fillColor = layer.fillColor
        self.position = layer.position
        self.actions = layer.actions
        self.zPosition = layer.zPosition
    }
    
    func getDistance(from point: CGPoint) -> CGFloat {
        dx = position.x - point.x
        dy = position.y - point.y
        return hypot(dx, dy)
    }
    
    func setPosition(_ point: CGPoint) -> CGPoint {
        position.x = point.x + dx
        position.y = point.y + dy
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
    
    private func getPositionFromNormValues(_ x: Double, _ y: Double) -> CGPoint {
        var point = CGPoint()
        point.x = x * bounds.width
        point.y = (1 - y) * bounds.height
        return point
    }
}

class MovingDot_XLocked: MovingDot {
    
    override func setPosition(_ point: CGPoint) -> CGPoint {
        position.y = point.y + dy
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
        position.x = point.x + dx
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
