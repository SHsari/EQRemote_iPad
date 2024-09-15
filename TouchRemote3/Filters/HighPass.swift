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
        response.dB = magnitudeTodB(omega2 / denominator)
        response.leafDidUpdate()
    }
    
}
