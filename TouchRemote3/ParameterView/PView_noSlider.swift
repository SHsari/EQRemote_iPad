//
//  PView_noSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//

import Foundation
import UIKit

class PView_noSlider: UIStackView, ParameterView, EQFilterDelegate {
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var QLabel: UILabel!
    
    var index: Int?
    
    var delegate: PViewDelegate?
    
    func setViewActive(_ isActive: Bool) {
        self.alpha = isActive ? 1.0 : 0.5
    }

    func setMenuByPreset(_ value: Int) {
        
    }
    func setSliderByPreset(_ value: Double) {
    
    }
    
    func setXLabel(x: Double) {
        freqLabel.text = String(format: "%.0f", x)
    }
    
    func setYLabel(y: Double) {
        QLabel.text = String(format: "%.2f", y)
    }
    
    func setZLabel(z: Double) {}
}
