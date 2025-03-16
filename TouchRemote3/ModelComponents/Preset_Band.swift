//
//  Enums.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/11/24.
//

import Foundation

// 프리셋 저장 구조.
// 프리셋 용도 뿐만 아니라 기본 파라미터 데이터를 담는 클래스입니다.

// Recordable은 Undo Redo시 task 목록에 담기 위한 프로토콜이고
// Codable은 Preset을 파일로 저장할 때를 위한 프로토콜입니다.

// Recordable을 설정하기 위해 Q값하나를 담기 위한 클래스
struct Zonly: Recordable {
    let z: Double
    func z_() -> Double { return z }
    init(_ z: Double) {
        self.z = z
    }
}

// 8개 밴드 또는 4개 밴드에 대한 모든 파라미터 값을 담는 Preset
class Preset: Recordable, Codable {
    
    var bands: [OneBand] = []
    init(bands: [OneBand]) {
        self.bands = bands
    }
    func copy() -> Preset {
        var bands: [OneBand] = []
        for band in self.bands {
            bands.append(band.copy())
        }
        let copy = Preset(bands: bands)
        return copy
    }
}

// x,y값, 즉 주파수와 게인값을 담는 클래스
struct XYPosition: Recordable, Equatable {
    var x: Double
    var y: Double
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    // 이거 왜햇지..???
    static func == (lhs: XYPosition, rhs: XYPosition) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// 주파수, 게인, Q값을 담는 클래스
class XYZPosition: Recordable, Codable {
    func copy(with zone: NSZone? = nil) -> XYZPosition {
        let copy = XYZPosition(x: x, y: y, z: z)
        return copy
    }
    func getXY() -> XYPosition {
        return XYPosition(x: x, y: y)
    }
    func getZ() -> Zonly {
        return Zonly(z)
    }
    
    var x: Double = 0.5
    var y: Double = 0.5
    var z: Double = 0.5
    init(x: Double = 0.5, y: Double = 0.5, z: Double = 0.5) {
        self.x = x
        self.y = y
        self.z = z
    }
    
}

// 위의 3개의 파라미터 + On/Off 여부와 필터 타입을 담는 클래스
class OneBand: Recordable, Codable {
    
    var type: FilterType
    var position: XYZPosition
    var isOn: Bool
    
    init(_ filterType: FilterType = .peak, _ position: XYZPosition = XYZPosition(), _ isOn: Bool = true) {
        self.type = filterType
        self.position = position
        self.isOn = isOn
    }
    
    func copy() -> OneBand {
        let copy = OneBand(type, position.copy(), isOn)
        return copy
    }
    
    func getXY() -> XYPosition {
        return XYPosition(x: position.x, y: position.y)
    }
    func getZ() -> Double {
        return position.z
    }
    func setXY(_ xy: XYPosition) {
        position.x = xy.x
        position.y = xy.y
    }
    func setZ(_ z: Double) {
        position.z = z
    }
}


enum Slope {
    
}

