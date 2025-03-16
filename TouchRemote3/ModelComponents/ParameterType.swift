//
//  ParameterType.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/30/24.
//

import Foundation
import UIKit

// 파라미터 타입 스트링 딕셔너리
let pTypeStringDict: [ParameterType : String] = [
    .x: "frequency",
    .y: "gain",
    .z: "Q",
    .band: "band",
    .dot: "dot",
]

enum ParameterType {
    case x
    case y
    case z
    case band
    case dot
}
// 복사 붙여넣기를 위한 프로토콜 선언입니다.
// 특정한 View에서 복사 요청이 오는 경우 해당 View의 파라미터 타입이 무엇인지 확인하는 용도입니다.
protocol ParameterTypeConfigurable: UIView {
    var pType: ParameterType {get set}
}
