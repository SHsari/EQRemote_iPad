//
//  ParameterType.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/30/24.
//

import Foundation
import UIKit

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

protocol ParameterTypeConfigurable: UIView {
    var pType: ParameterType {get set}
}
