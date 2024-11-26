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
    let stackView1 = UIStackView()
    
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

    func setInternalLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
                
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
    
    func setupActions() {
        xLock.addTarget(self, action: #selector(xLockToggled), for: .touchUpInside)
        yLock.addTarget(self, action: #selector(yLockToggled), for: .touchUpInside)
        
        self.addInteraction(UIContextMenuInteraction(delegate: self))
        xFreqView.addInteraction(UIContextMenuInteraction(delegate: self))
        yGainView.addInteraction(UIContextMenuInteraction(delegate: self))
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
    
    func updateSlider() {}
    
    func updateWhole() {
        updateXLabel(); updateYLabel(); updateZLabel()
        updateSlider()
    }

}

extension PView_noSlider: LabelSetDelegate {
    
    func didDoubleTap(at type: ParameterType) {
        if pType == .x {
            print("freq doubleTapped at index \(index)")
            delegate?.didDoubleTap_freq(at: index)
            updateXLabel()
        } else if pType == .y {
            print("freq doubleTapped at index \(index)")
            delegate?.didDoubleTap_gain(at: index)
            updateYLabel()
        }
    }
}
