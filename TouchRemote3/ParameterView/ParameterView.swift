//
//  ParameterView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//


import UIKit

let typePViewDict: [FilterType : String] = [
    .peak: "PView_withSlider",
    .lowPass: "PView_noSlider",
    .highPass: "PView_noSlider",
    .lowShelf: "PView_withSlider",
    .highShelf: "PView_withSlider"
]

protocol ParameterView: UIView {
    func setViewActive(_ isActive: Bool)
    var index: Int? { get set }
    var delegate: PViewDelegate? { get set }
    func setSliderByPreset(_ value: Double)
    func setMenuByPreset(_ value: Int)
}

protocol PViewDelegate: MainViewController {
    func pViewSliderMoved(_ index: Int, _ value: Double)
    func pViewSliderTouchEnded(_ index: Int)
    func pViewMenuChanged(_ type: Slope)
}



