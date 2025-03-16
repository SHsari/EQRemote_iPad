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
    func touchesEnded(_ index: Int)
}

// 터치를 이용한 파라미터 변경을 관장하는 View 입니다.
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

    func initialize(bindPositions: [XYZPosition]) {
        setupDoubleTap()
        let xyPositions = bindPositions.map { $0.getXY() }
        for (i, position) in xyPositions.enumerated() {
            let dot = MovingDot()
            dot.fillColor = colorDict[i].cgColor
            dot.superBounds = self.bounds
            dot.position = getPositionFromBindValues(position)
            dot.zPosition = CGFloat( i % sectionSize )
            allDots.append(dot)
            layer.addSublayer(dot)
        }
        setSectionActive(0)
    }
    // 더블 탭시 기본값으로 초기화 하는 로직.
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
        delegate?.touchesBegan(dotIndex)
        bringActiveLayerFront()
        let position = factoryPreset_().bands[dotIndex].getXY()
        let point = activeDot!.setPosition(getPositionFromBindValues(position))
        delegate?.touchesMoved(getBindValues(point))
        delegate?.touchesEnded(dotIndex)
    }
    
    // 표시된 점을 길게 누름으로서 복사 붙여넣기도 구현하려 했으나,
    // 골치아픈 부분이 많아서 TouchMeView는 구현하지 않았습니다.
    @objc func handleLongPress(){}

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            setClosestDot(touch.location(in: self))
            guard let dotIndex = activeDotIndex else {return}
            delegate?.touchesBegan(dotIndex)
            bringActiveLayerFront()
        }
    }
    
    // 최초 터치 위치를 바탕으로 몇번 점(밴드)의 파라미터를 변경할지 거리순으로 정합니다.
    // 터치 위치가 점들과 많이 떨어져 있으면 변경할 점을 설정하지 않습니다.
    private func setClosestDot(_ initPoint: CGPoint) {
        let closestDotInfo = dots.enumerated().compactMap{ (index , dot) -> (element: MovingDotPrtc, index: Int, distance: CGFloat)? in
            guard !dot.isHidden, !(dot is LockedDot) else {return nil}
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

    // 변경하는 점을 가장 앞으로 가져옵니다. 점들이 겹쳐있을 때 유효한 함수입니다.
    private func bringActiveLayerFront() {
        let indexedZ = activeDot!.zPosition
        for dot in dots {
            if dot.zPosition > indexedZ {
                dot.zPosition -= 1
            }
        }
        activeDot!.zPosition = 13
    }
    
    // 실시간으로 파라미터 값을 변경하라고 x, y값을 MainVC에 던집니다.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              self.bounds.contains(touch.location(in: self)),
              let activeDot = activeDot else { return }
        let location = touch.location(in: self)
        let position = activeDot.setPosition(location)
        delegate?.touchesMoved(getBindValues(position))
    }
    
    // 파라미터 변경이 완료되었음을 MainVC에 알립니다.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let index = activeDotIndex else { return }
        delegate?.touchesEnded(index)
        dots.forEach{$0.cleardXdY()}
    }

    // 각 좌표로부터 0~1사이의 노멀라이즈 된 값을 계산.
    private func getNormValues(_ point: CGPoint) -> XYPosition {
        let normX = point.x/bounds.width
        let normY = 1 - (point.y/bounds.height)
        return XYPosition(x: normX, y: normY)
    }

    // 노멀라이즈 된 값으로부터 실제 좌표를 구하기.
    private func getPositionFromNormValues(_ normP: XYPosition) -> CGPoint {
        var point = CGPoint()
        point.x = normP.x * bounds.width
        point.y = (1 - normP.y) * bounds.height
        return point
    }
    
    // 실제 의미있는 바인딩 된 벨류와 X,Y 좌표와의 관계
    private func getPositionFromBindValues(_ bindP: XYPosition) -> CGPoint {
        var point = CGPoint()
        point.x = Calculate.normX(bindP.x) * bounds.width
        point.y = (1-Calculate.normYwith(gain: bindP.y)) * bounds.height
        return point
    }
    
    private func getBindValues(_ point: CGPoint) -> XYPosition {
        let freq = Calculate.frequency(point.x/bounds.width)
        let gain = Calculate.gain(1 - point.y/bounds.height)
        return XYPosition(x: freq, y: gain)
    }
}

extension TouchMeView {
    // 섹션이 바뀔 때 표시되는 점들을 바꿉니다.
    // 비활성화 섹션 점들은 투명도가 높아집니다. 터치도 먹지 않습니다.
    func setSectionActive(_ section: Int) {
        for (i, dot) in allDots.enumerated() {
            dot.opacity = 0.2; dot.zPosition = CGFloat(i % 4)
        }
        self.offset = section*sectionSize
        dots = Array(allDots[offset..<offset+sectionSize])
        dots.forEach{ $0.opacity = 1.0; $0.zPosition += 10 }
    }

    // 특정 밴드의 on/off 스위치가 토글될 때 호출되는 함수,.
    func setDotActive(_ index: Int, isActive: Bool) {
        allDots[index].isHidden = !isActive
    }
    
    // 축 잠금에 대응하는 함수
    func xLockToggled(at index: Int) {
        let dot = allDots[index].xLockToggled()
        layer.addSublayer(dot)
        allDots[index] = dot
        dots = Array(allDots[offset..<offset+sectionSize])
    }
    
    func yLockToggled(at index: Int) {
        let dot = allDots[index].yLockToggled()
        layer.addSublayer(dot)
        allDots[index] = dot
        dots = Array(allDots[offset..<offset+sectionSize])
    }
    
    // 이거 왜 만들었지..?
    func resetDotLock(at index: Int) {
        let dot = allDots[index].resetLock()
        layer.addSublayer(dot)
        allDots[index] = dot
        dots = Array(allDots[offset..<offset+sectionSize])
    }

    // 프리셋 로딩이나 redo undo시에 축잠금 여부와 상관없이 점을 옮겨야 할 때 사용하는 함수일 겁니다.
    func setPositionDirect(at index: Int, norm: XYPosition) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        allDots[index].position = getPositionFromNormValues(norm)
    }
    // 위에는 노멀라이즈 된 값ㅡ, 여기는 실제 의미있는 파라미터값.
    func setPositionDirect(at index: Int, bind: XYPosition) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        allDots[index].position = getPositionFromBindValues(bind)
    }
    
    // 뭐지 이거 타이핑으로 파라미터 변경시 사용되는 함수인가..? 여튼.
    //.위에는 x,y값이 묶음으로 바뀌는 상황이고
    // 여기는 x 또는 y값이 개별로 바뀔때 호출하는 함수 같습니다.
    func setXwith(nvalue: Double, at index: Int) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        activeDot?.position.x = nvalue * bounds.width
    }
    func setYwith(nvalue: Double, at index: Int) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        activeDot?.position.y = (1-nvalue) * bounds.height
    }
    
    // 더블탭: 즉 초기화 시에 호출되는 함수일겁니다.
    func doubleTapped(at index: Int, norm: XYPosition) {
        activeDot = allDots[index]
        bringActiveLayerFront()
        let newPosition = getPositionFromNormValues(norm)
        allDots[index].position = newPosition
        delegate?.touchesMoved(getBindValues(newPosition))
    }
}
