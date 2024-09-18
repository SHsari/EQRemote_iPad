//
//  EQFilter.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation


protocol EQFilterPrtc {
    func setX()
    func setY()
    func setZ()
    func updateResponse()
    init(_ index: Int)
}

protocol EQFilterDelegate: ParameterView {
    func setXLabel(x: Double)
    func setYLabel(y: Double)
    func setZLabel(z: Double)
}

class EQFilterClass {
    
    var xyz: XYZPosition
    var freq = 1000.0
    var gain = 0.0
    var Q = 1.0
    var response: Response
    
    weak var delegate: EQFilterDelegate?
    
    init(_ index: Int) {
        self.delegate = parameterViewArray[index] as? EQFilterDelegate
        self.response = allResponse[index]
        self.xyz = globalBands[index].position
    }
}

enum FilterType {
    case peak
    case lowPass
    case highPass
    case lowShelf
    case highShelf
}

