//
//  PView_withSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//
/*
import Foundation
import UIKit

class PView_test: UIStackView, ParameterView, EQFilterDelegate {
    
    
    weak var delegate: PViewDelegate?
    
    var index: Int?
    
    @IBAction func sliderTouchBegin(_ sender: UISlider) {
        delegate?.pViewSliderTouchBegin(index!)
    }
    
    @IBAction func sliderTouchEnd(_ sender: UISlider) {
        delegate?.pViewSliderTouchEnded(index!)
    }
    @IBAction func QSliderMoved(_ sender: UISlider) {
        delegate?.pViewSliderMoved(index!, Double(sender.value))
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setViewActive(_ isActive: Bool) {
        QSlider.isEnabled = isActive
        self.alpha = isActive ? 1.0 : 0.5
    }
    func setMenuByPreset(_ value: Int) {
        
    }
    
    func setSliderByPreset(_ value: Double) {
        self.QSlider.setValue(Float(value), animated: true)
    }
    
    func setXLabel(x: Double) {
        freqLabel.text = String(format: "%.0f", x)
    }
    
    func setYLabel(y: Double) {
        gainLabel.text = String(format: "%.2f", y)
    }
    
    func setZLabel(z: Double) {
        QLabel.text = String(format: "%.2f", z)
    }
}
*/
