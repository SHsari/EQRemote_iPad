//
//  Enums.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/11/24.
//

import Foundation

struct Zonly: Recordable {
    let z: Double
    func z_() -> Double { return z }
    init(_ z: Double) {
        self.z = z
    }
}

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

struct XYPosition: Recordable, Equatable {
    var x: Double
    var y: Double
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    static func == (lhs: XYPosition, rhs: XYPosition) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

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

class OneBand: Recordable, Codable {
    
    var type: FilterType
    var position: XYZPosition
    var isOn: Bool
    
    init(_ filterType: FilterType = .peak, _ position: XYZPosition = XYZPosition(), _ isOn: Bool = true) {
        self.type = filterType
        self.position = position.copy()
        self.isOn = isOn
    }
    
    func copy() -> OneBand {
        let copy = OneBand(type, position, isOn)
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

