//
//  BandController.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/18/24.
//

import Foundation


protocol ParameterStoragePrtc {
    var norm: XYZPosition { get set }
    var bind: XYZPosition { get set }
    func setBindX(_ x: Double)
    func setBindY(_ y: Double)
    func setBindZ(_ z: Double)
    func setNormX(_ x: Double)
    func setNormY(_ y: Double)
    func setNormZ(_ z: Double)
    func setPositions(_ norm: XYZPosition, _ bind: XYZPosition)
}

class ParameterBinder {
    private init() {}
    static let globalBinderDict: [FilterType : ParameterStoragePrtc] = [
        .peak: PeakStorage(),
        .lowPass: PassStorage(),
        .highPass: PassStorage(),
        .lowShelf: ShelfStorage(),
        .highShelf: ShelfStorage()
    ]
}


class PeakStorage: ParameterStoragePrtc {
    
    var norm: XYZPosition = XYZPosition()
    var bind: XYZPosition = XYZPosition()
    func setNormX(_ x: Double) { norm.x = x; bind.x = Calculate.frequency(x) }
    func setNormY(_ y: Double) { norm.y = y; bind.y = Calculate.gain(y) }
    func setNormZ(_ z: Double) { norm.z = z; bind.z = Calculate.peakQ(z) }
    func setBindX(_ x: Double) { bind.x = x; norm.x = Calculate.normX(x) }
    func setBindY(_ y: Double) { bind.y = y; norm.y = Calculate.normYwith(gain: y) }
    func setBindZ(_ z: Double) { bind.z = z; norm.z = Calculate.normZwith(peakQ: z) }
    func setPositions(_ norm: XYZPosition, _ bind: XYZPosition) {
        self.bind = bind; self.norm = norm;
        setNormX(norm.x); setNormY(norm.y); setNormZ(norm.z);
    }
}

class PassStorage: ParameterStoragePrtc {

    var norm: XYZPosition = XYZPosition()
    var bind: XYZPosition = XYZPosition()
    func setNormX(_ x: Double) { norm.x = x; bind.x = Calculate.frequency(x) }
    func setNormY(_ y: Double) { norm.y = y; bind.y = Calculate.passQ(y) }
    func setNormZ(_ z: Double) { }
    func setBindX(_ x: Double) { bind.x = x; norm.x = Calculate.normX(x) }
    func setBindY(_ y: Double) { bind.y = y; norm.y = Calculate.normYwith(passQ: y) }
    func setBindZ(_ z: Double) { }
    func setPositions(_ norm: XYZPosition, _ bind: XYZPosition) {
        self.bind = bind; self.norm = norm;
        setNormX(norm.x); setNormY(norm.y); setNormZ(norm.z);
    }
}

class ShelfStorage: ParameterStoragePrtc {

    var norm: XYZPosition = XYZPosition()
    var bind: XYZPosition = XYZPosition()
    func setNormX(_ x: Double) { norm.x = x; bind.x = Calculate.frequency(x) }
    func setNormY(_ y: Double) { norm.y = y; bind.y = Calculate.gain(y) }
    func setNormZ(_ z: Double) { norm.z = z; bind.z = Calculate.shelfQ(z) }
    func setBindX(_ x: Double) { bind.x = x; norm.x = Calculate.normX(x) }
    func setBindY(_ y: Double) { bind.y = y; norm.y = Calculate.normYwith(gain: y) }
    func setBindZ(_ z: Double) { bind.z = z; norm.z = Calculate.normZwith(shelfQ: z) }
    func setPositions(_ norm: XYZPosition, _ bind: XYZPosition) {
        self.bind = bind; self.norm = norm;
        setNormX(norm.x); setNormY(norm.y); setNormZ(norm.z);
    }
}
