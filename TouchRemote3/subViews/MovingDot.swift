//
//  MovingDot.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/18/24.
//

import UIKit

class MovingDot: CAShapeLayer {
    var dx: Double = 0.0
    var dy: Double = 0.0
    
    override init() { super.init() }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        guard layer is MovingDot else { fatalError("unable to Copy movingDot instance") }
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
}

class MovingDot_YLocked: MovingDot {
    override func setPosition(_ point: CGPoint) -> CGPoint {
        position.x = point.x + dx
        return position
    }
}

class LockedDot: MovingDot {
    override func setPosition(_ point: CGPoint) -> CGPoint {
        return position
    }
}
