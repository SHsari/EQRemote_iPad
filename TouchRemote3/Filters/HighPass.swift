//
//  HighPass.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation

class HighPass: EQFilterClass, EQFilterPrtc {
    
    private lazy var w0 = pi2 * freq
    private lazy var w02 = w0^2
    private lazy var w02_w2 = w02 - omega2
    
    var freq: Double { bind.x }
    var Q: Double { bind.y }
    
    override func initialize(_ response: Response, _ norm: XYZPosition, _ bind: XYZPosition) {
        super.initialize(response, norm, bind)
        setNormX(norm.x); setNormY(norm.y); setNormZ(norm.z);
        updateResponse()
    }

    func setNormX(_ x: Double) {
        norm.x = x; bind.x = Calculate.frequency(x)
        xDidSet()
    }
    
    func setBindX(_ x: Double) {
        bind.x = x; norm.x = Calculate.normX(x)
        xDidSet()
    }
    
    func setNormY(_ y: Double) {
        norm.y = y
        bind.y = Calculate.passQ(y)
    }
    
    func setBindY(_ y: Double) {
        bind.y = y
        norm.y = Calculate.normYwith(passQ: y)
    }
    
    func setNormZ(_ z: Double) { }
    func setBindZ(_ z: Double) { }
    
    private func xDidSet() {
        w0 = pi2 * freq
        w02 = w0^2
        w02_w2 = w02 - omega2
    }
    
    func updateResponse() {
        let w0wDivQ = omega*w0 / Q
        let denominator = magnitudeComplex(w02_w2, w0wDivQ)
        response.dB = magnitudeTodB(omega2 / denominator)
    }
    
}
