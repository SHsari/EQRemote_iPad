//
//  MovingDot.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/18/24.
//

import UIKit

// Touch Me View에서
// 밴드별로 Frequency와 gain값을 x, y좌표로 변환하여 해당 위치에
// 아래 movingDot 클래스를 화면에 보여줍니다.
//
protocol MovingDotPrtc: MovingDot {
    func getDistance(from point: CGPoint) -> CGFloat
    func setPosition(_ point: CGPoint) -> CGPoint
    func xLockToggled() -> MovingDotPrtc
    func yLockToggled() -> MovingDotPrtc
    func set(layer: MovingDot)
}

// MovingDot 클래스는 CAShapeLayer를 상속합니다.
// 즉 어떤 모양을 보여주는 클래스입니다.
// 원형 모양이고 이렇게 여러가지 종류가 있는 이유는,
// X축이 잠긴 상태일 때,
// Y축이 잠기 상태일 때에 대해서 대응하는 클래스를 모두 따로 만들었기 때문입니다.

// 알고리즘한 50문제 더 풀고와서 느끼는 것이지만, 아마
// 그냥 각 축별로 lock 여부를 if문으로 확인하고 좌표를 설정하는게 빠르지 않을까 싶네요..?

// 함수형 언어 같은건가??


// 기본 클래스: 잠김이 없을 때.
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
    
    // 정상적으로 x,y를 터치포지션에 맞추어 모두 업데이트 합니다.
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
    
    // xLock이 눌렸을 때, XLock Moving Dot으로 클래스를 변경합니다.
    func xLockToggled() -> MovingDotPrtc {
        self.removeFromSuperlayer()
        let dot = MovingDot_XLocked()
        dot.set(layer: self)
        return dot
    }
    // yLock이 눌렸을 때 위와 동일하게 대응합니다.
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

// 모두 잠겼을때
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
