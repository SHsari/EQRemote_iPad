//
//  HighPass.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation

class HighShelf: EQFilterClass, EQFilterPrtc {
    
    //imediate Variable//
    private lazy var A = pow(10, gain/40)
    private lazy var sqrtA = sqrt(A)
    private lazy var w0 = pi2 * freq
    private lazy var w02 = w0^2
    
    var freq: Double { bind.x }
    var gain: Double { bind.y }
    var Q: Double { bind.z }
    
    func initialize(_ response: Response, _ norm: XYZPosition, _ bind: XYZPosition) {
        self.response = response
        self.bind = bind; self.norm = norm;
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
        bind.z = Calculate.shelfQ(z)
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
        norm.z = Calculate.normZwith(shelfQ: z)
    }
    
    private func xDidSet() {
        w0 = pi2 * freq
        w02 = w0^2
    }
    
    private func yDidSet() {
        A = pow(10, gain/40)
        sqrtA = sqrt(A)
    }
    
    func updateResponse() {
        let numeReal = w02 - omega2*A
        let denoReal = w02*A - omega2
        let imag = omega * w0 * sqrtA / Q
        let numerator = magnitudeComplex(numeReal, imag)
        let denominator = magnitudeComplex(denoReal, imag)
        self.response.dB = magnitudeTodB( A * numerator/denominator )
        response.responseDidUpdate()
    }
}
