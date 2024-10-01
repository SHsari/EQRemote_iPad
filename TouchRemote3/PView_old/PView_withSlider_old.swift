//
//  PView_withSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//
/*
import Foundation
import UIKit

class PView_withSlider: PViewClass, ParameterView {
    
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var QLabel: UILabel!
    @IBOutlet weak var QSlider: UISlider!
    
    @IBAction func xLockToggled(_ sender: LockButton) {
        delegate?.xLocktoggled(at: self.index)
    }
    @IBAction func yLockToggled(_ sender: LockButton) {
        delegate?.yLocktoggled(at: self.index)
    }
    
    @IBAction func sliderTouchBegin(_ sender: UISlider) {
        delegate?.sliderTouchesBegan(index)
    }
    
    @IBAction func sliderTouchEnd(_ sender: UISlider) {
        delegate?.sliderTouchesEnded()
    }
    @IBAction func QSliderMoved(_ sender: UISlider) {
        delegate?.sliderMoved(Double(sender.value))
        updateZLabel()
    }
    
    func setViewActive(_ isActive: Bool) {
        QSlider.isEnabled = isActive
        self.alpha = isActive ? 1.0 : 0.5
    }
    
    func updateSlider(_ z: Double) {
        self.QSlider.setValue(Float(z), animated: true)
    }
    
    func updateXLabel() {
        freqLabel.text = String(format: "%.0f", bind.x)
    }
    
    func updateYLabel() {
        gainLabel.text = String(format: "%.2f", bind.y)
    }
    
    func updateZLabel() {
        QLabel.text = String(format: "%.2f", bind.z)
    }
}
*/
