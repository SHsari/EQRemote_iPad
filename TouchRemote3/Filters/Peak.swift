//
//  Peak.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation

class Peak: EQFilterClass, EQFilterPrtc {
    
    //intermediate Variables//
    private lazy var A = pow(10, gain/40)
    private lazy var w0 = pi2 * freq
    private lazy var w02_w2 = w0^2 - omega2
    
    required override init(_ index: Int) {
        super.init(index)
        setX()
        setY()
        setZ()
        updateResponse()
    }
    
    func setX() {
        self.freq = Calculate.frequency(xyz.x)
        w0 = pi2 * freq
        w02_w2 = w0^2 - omega2
        delegate?.setXLabel(x: freq)
    }
    
    func setY() {
        self.gain = Calculate.gain(xyz.y)
        A = pow(10, gain/40)
        delegate?.setYLabel(y: gain)
    }
    
    func setZ() {
        self.Q = Calculate.peakQ(xyz.z)
        self.delegate?.setZLabel(z: Q)
    }
    
    func updateResponse() {
        let w0wDivQ = w0/Q * omega
        let numerator = magnitudeComplex(w02_w2, w0wDivQ*A)
        let denominator = magnitudeComplex(w02_w2, w0wDivQ/A)
        response.dB = magnitudeTodB( numerator / denominator )
        response.responseDidUpdate()
    }

}
/*

func biquadPrint() {
    let w0 = w0 / 44100
    let cosw0 = cos(w0)
    let alpha = sin(w0) / (2*Q)
    let a0 = 1 + alpha/A
    var a1 = -2*cosw0
    var a2 = 1-alpha/A
    var b0 = 1 + alpha*A
    var b1 = -2 * cosw0
    var b2 = 1 - alpha*A
    a1 /= a0
    a2 /= a0
    b0 /= a0
    b1 /= a0
    b2 /= a0
    print("a1: \(a1), a2: \(a2), b0: \(b0), b1: \(b1), b2: \(b2)")
}
*/
