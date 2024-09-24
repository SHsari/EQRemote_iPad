//
//  EQFilter.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation


protocol EQFilterPrtc {
    func updateResponse()
    var norm: XYZPosition { get set }
    var bind: XYZPosition { get set }
    func setBindX(_ x: Double)
    func setBindY(_ y: Double)
    func setBindZ(_ z: Double)
    func setNormX(_ x: Double)
    func setNormY(_ y: Double)
    func setNormZ(_ z: Double)
    func initialize(_ response: Response, _ norm: XYZPosition, _ bind: XYZPosition)
}

class EQFilterClass {
    var norm = XYZPosition()
    var bind = XYZPosition()
    var response = Response()
    
    static let typeDict: [FilterType : () -> EQFilterPrtc] = [
        .peak: { Peak() },
        .lowPass: { LowPass() },
        .highPass: { HighPass() },
        .lowShelf: { LowShelf () },
        .highShelf: { HighShelf() },
    ]
}


enum FilterType {
    case peak
    case lowPass
    case highPass
    case lowShelf
    case highShelf
}

