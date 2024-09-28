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
    var index: Int { get set }
    var delegate: PViewDelegate? { get set }
    func initialize(_ position: XYZPosition, _ index: Int, _ delegate: PViewDelegate)
    func updateXLabel()
    func updateYLabel()
    func updateZLabel()
    func updateSlider(_ z: Double)
    func setViewActive(_ isActive: Bool)
}

class PViewClass: UIStackView {
    var index: Int = -1
    weak var delegate: PViewDelegate?
    internal var bind = XYZPosition()
    func initialize(_ position: XYZPosition, _ index: Int, _ delegate: PViewDelegate) {
        self.bind = position
        self.index = index
        self.delegate = delegate
    }
}

protocol PViewDelegate: MainViewController {
    func sliderTouchesBegan(_ index: Int)
    func sliderMoved(_ value: Double)
    func sliderTouchesEnded()
    func xLocktoggled(at index: Int)
    func yLocktoggled(at index: Int)
}



