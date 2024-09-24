//
//  PView_noSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//

import Foundation
import UIKit

class PView_noSlider: PViewClass, ParameterView {
    
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var QLabel: UILabel!

    func setViewActive(_ isActive: Bool) {
        self.alpha = isActive ? 1.0 : 0.5
    }

    func updateXLabel() {
        freqLabel.text = String(format: "%.0f", bind.x)
    }
    
    func updateYLabel() {
        QLabel.text = String(format: "%.2f", bind.y)
    }
    
    func updateZLabel() {}
    func updateSlider(_ z: Double) {}
}
