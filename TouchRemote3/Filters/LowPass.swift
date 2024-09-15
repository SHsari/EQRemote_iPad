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
    
    required override init(_ index: Int) {
        super.init(index)
        setX()
        setY()
        updateResponse()
    }
    
    func setX() {
        freq = Calculate.frequency(xyz.x)
        delegate?.setXLabel(x: freq)
        w0 = pi2 * freq
        w02 = w0^2
        w02_w2 = w02 - omega2
    }
    
    func setY() {
        self.Q = Calculate.passQ(xyz.y)
        delegate?.setYLabel(y: Q)
    }
    
    func setZ() { }
    
    func updateResponse() {
        let w0wDivQ = omega*w0 / Q
        let denominator = magnitudeComplex(w02_w2, w0wDivQ)
        response.dB = magnitudeTodB(w02 / denominator)
        response.leafDidUpdate()
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
