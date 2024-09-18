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
    
    required override init(_ index: Int) {
        super.init(index)
        setX()
        setY()
        setZ()
        updateResponse()
    }
    
    func setY() {
        self.gain = Calculate.gain(xyz.y)
        delegate?.setYLabel(y: gain)
        A = pow(10, gain/40)
        sqrtA = sqrt(A)
    }
    
    func setX() {
        self.freq = Calculate.frequency(xyz.x)
        delegate?.setXLabel(x: freq)
        w0 = pi2 * freq
        w02 = w0^2
    }
    
    func setZ() {
        self.Q = Calculate.shelfQ(xyz.z)
        self.delegate?.setZLabel(z: self.Q)
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
