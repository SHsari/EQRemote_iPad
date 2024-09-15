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

let defaultXPosition = [0.2, 0.4, 0.6, 0.8, 0.15, 0.35, 0.65, 0.85]
let defaultFilterType: [FilterType] = [.peak, .peak, .peak, .peak, .lowShelf, .peak, .peak, .highShelf]
let factoryPreset = factoryPreset_()
let factoryPosition = factoryPreset.bands.map{ $0.getXY() }

func freqToNormPosition(freq: Int) {
    
}

func factoryPreset_() -> Preset {
    var bands: [OneBand] = []
    for i in 0..<numberOfBands {
        let x = defaultXPosition[i]
        let y = 0.5
        let z = 0.5
        let xyz = XYZPosition(x: x, y: y, z: z)
        let band = OneBand(defaultFilterType[i], xyz)
        bands.append(band)
    }
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

