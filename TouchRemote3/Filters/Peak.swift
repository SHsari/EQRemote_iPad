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
    
    private var freq: Double { bind.x }
    private var gain: Double { bind.y }
    private var Q: Double { bind.z }
    
    override func initialize(_ response: Response, _ norm: XYZPosition, _ bind: XYZPosition) {
        super.initialize(response, norm, bind)
        setNormX(norm.x); setNormY(norm.y); setNormZ(norm.z);
        updateResponse()
    }
    
    func setNormX(_ x: Double) {
        norm.x = x
        bind.x = Calculate.frequency(x)
        xDidSet()
    }
    
    func setNormY(_ y: Double) {
        norm.y = y
        bind.y = Calculate.gain(y)
        yDidSet()
    }
    
    func setNormZ(_ z: Double) {
        norm.z = z
        bind.z = Calculate.peakQ(z)
    }
    func setBindX(_ x: Double) {
        bind.x = x
        norm.x = Calculate.normX(x)
        xDidSet()
    }
    func setBindY(_ y: Double) {
        bind.y = y
        norm.y = Calculate.normYwith(gain: y)
        yDidSet()
    }
    func setBindZ(_ z: Double) {
        bind.z = z
        norm.z = Calculate.normZwith(peakQ: z)
    }
    
    private func xDidSet() {
        w0 = pi2 * freq
        w02_w2 = w0^2 - omega2
    }
    private func yDidSet() { A = pow(10, gain/40) }
    
    func updateResponse() {
        let w0wDivQ = w0/Q * omega
        let numerator = magnitudeComplex(w02_w2, w0wDivQ*A)
        let denominator = magnitudeComplex(w02_w2, w0wDivQ/A)
        response.dB = magnitudeTodB( numerator / denominator )
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
