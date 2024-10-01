//
//  PView_noSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/27/24.
//

import UIKit

class PView_noSlider: PViewClass, ParameterView {
    
    let xFreqView = LabelSet_freq()
    let yGainView = LabelSet_gain()
    let zQView = LabelSet_peakQ()
    
    lazy var freqLabel = xFreqView.mainLabel
    lazy var gainLabel = yGainView.mainLabel
    lazy var QLabel = zQView.mainLabel
    
    lazy var xLock = xFreqView.lockButton
    lazy var yLock = yGainView.lockButton
    
    override func initialize(_ position: XYZPosition, _ index: Int, _ delegate: any PViewDelegate) {
        super.initialize(position, index, delegate)
        
        xFreqView.delegate = self
        yGainView.delegate = self
        
        setInternalLayout()
        setupActions()
    }
    
    func setupActions() {
        xLock.addTarget(self, action: #selector(xLockToggled), for: .touchUpInside)
        yLock.addTarget(self, action: #selector(yLockToggled), for: .touchUpInside)
        
        self.addInteraction(UIContextMenuInteraction(delegate: self))
        xFreqView.addInteraction(UIContextMenuInteraction(delegate: self))
        yGainView.addInteraction(UIContextMenuInteraction(delegate: self))
    }
    
    func setInternalLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
                
        let stackView1 = UIStackView()
        addArrangedSubview(stackView1)
        addArrangedSubview(zQView)
        
        NSLayoutConstraint.activate([
            stackView1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView1.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            zQView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
        ])
        
        stackView1.axis = .horizontal
        stackView1.alignment = .fill
        stackView1.distribution = .fillEqually
        stackView1.addArrangedSubview(xFreqView)
        stackView1.addArrangedSubview(yGainView)
    }
    
    
    @objc private func xLockToggled() {
        delegate?.xLocktoggled(at: index)
    }
    @objc private func yLockToggled() {
        delegate?.yLocktoggled(at: index)
    }
    
    //ParameterView
    func updateXLabel() {
        freqLabel.text = String(format: "%.0f", bind.x)
    }
    
    func updateYLabel() {
        gainLabel.text = String(format: "%.2f", bind.y)
        QLabel.text = String(format: "%.2f", bind.z)
    }
    
    func updateZLabel() {}
    
    func updateSlider(_ value: Double) {}
    
    func updateWhole(_ slider: Double) {
        updateXLabel(); updateYLabel(); updateZLabel()
        updateSlider(slider)
    }

}

extension PView_noSlider: LabelSetDelegate {
    func didDoubleTap(at type: ParameterType) {
        func didDoubleTap(at pType: ParameterType) {
            if pType == .x {
                delegate?.didDoubleTap_freq(at: index)
            } else if pType == .y {
                delegate?.didDoubleTap_gain(at: index)
                updateYLabel()
            }
        }
    }
}
