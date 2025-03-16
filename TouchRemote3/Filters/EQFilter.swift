//
//  EQFilter.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation

// 타입별로 서로 다른 계산함수가 필요합니다.
// 타입별로 클래스를 만들었으며,
// 이 클래스들이 만족해야하는 최소조건명세가 다음과 같습니다.
// 또 이런 클래스(또는 프로토콜)을 통해서 쉽게 접근이 가능하죠. 
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
    
    func initialize(_ response: Response, _ norm: XYZPosition, _ bind: XYZPosition) {
        self.response = response
        self.norm = norm
        self.bind = bind
    }
    
    static let typeDict: [FilterType : () -> EQFilterPrtc] = [
        .peak: { Peak() },
        .lowPass: { LowPass() },
        .highPass: { HighPass() },
        .lowShelf: { LowShelf() },
        .highShelf: { HighShelf() },
    ]
}


enum FilterType: Codable {
    case peak
    case lowPass
    case highPass
    case lowShelf
    case highShelf
}

