//
//  PView_noSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//
/*
 
 let typePViewDict: [FilterType : String] = [
     .peak: "PView_withSlider",
     .lowPass: "PView_noSlider",
     .highPass: "PView_noSlider",
     .lowShelf: "PView_withSlider",
     .highShelf: "PView_withSlider"
 ]
 
import Foundation
import UIKit

class PView_noSlider: PViewClass, ParameterView {
    
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var QLabel: UILabel!

    @IBAction func xLockToggled(_ sender: LockButton) {
        delegate?.xLocktoggled(at: index)
    }
    @IBAction func yLockToggled(_ sender: LockButton) {
        delegate?.yLocktoggled(at: index)
    }
    
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
*/
