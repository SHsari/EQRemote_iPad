//
//  PView_withSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//

import Foundation
import UIKit

class PView_test: PViewClass, ParameterView {
    
    @IBAction func sliderTouchBegan(_ sender: UISlider) {
        delegate?.sliderTouchesBegan(index)
    }
    
    @IBAction func sliderTouchEnd(_ sender: UISlider) {
        delegate?.sliderTouchesEnded()
    }
    @IBAction func QSliderMoved(_ sender: UISlider) {
        delegate?.sliderMoved(Double(sender.value))
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setViewActive(_ isActive: Bool) {  }
    
    func updateSlider(_ value: Double) {}
    
    func updateXLabel() {}
    
    func updateYLabel() {}
    
    func updateZLabel() {}
}

