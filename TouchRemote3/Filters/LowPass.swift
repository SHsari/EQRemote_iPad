//
//  LowPass.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation

class LowPass: EQFilterClass, EQFilterPrtc {
    
    private lazy var w0 = pi2 * freq
    private lazy var w02 = w0^2
    private lazy var w02_w2 = w02 - omega2
    
    var freq: Double { bind.x }
    var Q: Double { bind.z }
    
    override func initialize(_ response: Response, _ norm: XYZPosition, _ bind: XYZPosition) {
        super.initialize(response, norm, bind)
        setBindX(bind.x); setBindY(bind.y); setBindZ(bind.z);
        updateResponse()
    }

    func setNormX(_ x: Double) {
        norm.x = x; bind.x = Calculate.frequency(x)
        xDidSet()
    }
    
    func setNormY(_ y: Double) {
        norm.y = y
        bind.y = Calculate.gain(y)
        bind.z = Calculate.passQ(y)
    }
    
    func setBindX(_ x: Double) {
        bind.x = x; norm.x = Calculate.normX(x)
        xDidSet()
    }
    
    func setBindY(_ y: Double) {
        bind.y = y
        norm.y = Calculate.normYwith(gain: y)
        bind.z = Calculate.passQ(norm.y)
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
        response.dB = magnitudeTodB(w02 / denominator)
    }
    
    
}

/*
func biquadPrint() {
    let w0 = w0 / 44100
    let cosw0 = cos(w0)
    let alpha = sin(w0) / (2*Q)
    
    let a0 = 1+alpha
    var a1 = -2*cosw0
    var a2 = 1-alpha
    var b0 = (1-cosw0)/2
    var b1 = 1-cosw0
    var b2 = (1-cosw0)/2
    a1 /= a0
    a2 /= a0
    b0 /= a0
    b1 /= a0
    b2 /= a0
    print("a1: \(a1), a2: \(a2), b0: \(b0), b1: \(b1), b2: \(b2)")
}
*/
