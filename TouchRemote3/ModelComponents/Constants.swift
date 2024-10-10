//
//  EnumsAndConstants.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation
import UIKit

let numberOfBands = 8
let sectionSize = numberOfBands/2

let defaultFilterType: [FilterType] = [.peak, .peak, .peak, .peak, .lowShelf, .peak, .peak, .highShelf]

let factoryPosition = factoryPreset_().bands.map{ $0.position }

let typeStringDict: [FilterType : String] = [
    .peak: "Peak",
    .lowPass: "LowPass",
    .highPass: "HighPass",
    .lowShelf: "LowShelf",
    .highShelf: "HighShelf"
]

func factoryPreset_() -> Preset {
    let bands: [OneBand] = [
        OneBand(.peak, XYZPosition(x: 80, y: 0.0, z: 1.7)),
        OneBand(.peak, XYZPosition(x: 300, y: 0.0, z: 1.7)),
        OneBand(.peak, XYZPosition(x: 1000, y: 0.0, z: 1.7)),
        OneBand(.peak, XYZPosition(x: 5000, y: 0.0, z: 1.7)),
        OneBand(.lowShelf, XYZPosition(x: 50, y: 0.0, z: 1.5)),
        OneBand(.peak, XYZPosition(x: 200, y: 0.0, z: 1.7)),
        OneBand(.peak, XYZPosition(x: 2000, y: 0.0, z: 1.7)),
        OneBand(.highShelf, XYZPosition(x: 8000, y: 0.0, z: 1.5))
    ]
    return Preset(bands: bands)
}


let red1 = UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0)
let yellow1 = UIColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 1.0)
let mint1 = UIColor(red: 0.3, green: 0.8, blue: 0.6, alpha: 1.0)
let purple1 = UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
let brick2 = UIColor(red: 0.8, green: 0.4, blue: 0.4, alpha: 1.0)
let indigo2 = UIColor(red: 0.4, green: 0.4, blue: 0.8, alpha: 1.0)
let green2 = UIColor(red: 0.35, green: 0.6, blue: 0.35, alpha: 1.0)
let orange2 = UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)

// 컬러를 배열에 추가
let colorDict = [red1, yellow1, mint1, purple1, brick2, indigo2, green2, orange2]

