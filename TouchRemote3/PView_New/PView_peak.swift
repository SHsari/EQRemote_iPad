//
//  PView_withSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/27/24.
//

import UIKit

class PView_peak: PViewClass, ParameterView {
    
    let xFreqView = LabelSet_freq()
    let yGainView = LabelSet_gain()
    let zQView = LabelSet_peakQ()
    let QSlider = ZSlider()
    
    lazy var freqLabel = xFreqView.mainLabel
    lazy var gainLabel = yGainView.mainLabel
    lazy var QLabel = zQView.mainLabel
    
    lazy var xLock = xFreqView.lockButton
    lazy var yLock = yGainView.lockButton
    
    override func initialize(_ position: XYZPosition, _ index: Int, _ delegate: any PViewDelegate) {
        super.initialize(position, index, delegate)
        
        xFreqView.delegate = self
        yGainView.delegate = self
        zQView.delegate = self
        
        setInternalLayout()
        setupActions()
    }

    func setInternalLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
                
        let stackView1 = UIStackView()
        addArrangedSubview(stackView1)
        addArrangedSubview(QSlider)
        addArrangedSubview(zQView)
        
        NSLayoutConstraint.activate([
            stackView1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView1.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            zQView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            QSlider.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8)
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
        zQView.addInteraction(UIContextMenuInteraction(delegate: self))
        
        QSlider.addTarget(self, action: #selector(sliderTouchesBegan), for: .touchDown)
        QSlider.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        QSlider.addTarget(self, action: #selector(sliderTouchesEnded), for: .touchUpInside)
    }

    @objc private func xLockToggled() {
        delegate?.xLocktoggled(at: index)
    }
    @objc private func yLockToggled() {
        delegate?.yLocktoggled(at: index)
    }
    
    @objc private func sliderTouchesBegan() {
        delegate?.sliderTouchesBegan(index)
    }
    @objc private func sliderMoved() {
        let rValue = Calculate.peakQ(Double(QSlider.value))
        delegate?.sliderMoved(rValue)
        updateZLabel()
    }
    @objc private func sliderTouchesEnded() {
        delegate?.sliderTouchesEnded()
    }

    
    //ParameterView
    func updateXLabel() {
        freqLabel.text = String(format: "%.0f", bind.x)
    }
    
    func updateYLabel() {
        gainLabel.text = String(format: "%.2f", bind.y)
    }
    
    func updateZLabel() {
        QLabel.text = String(format: "%.2f", bind.z)
    }
    
    func updateSlider() {
        QSlider.value = Float( Calculate.normZwith(peakQ: bind.z) )
        updateZLabel()
    }
    func updateWhole() {
        updateXLabel(); updateYLabel(); updateSlider()
    }

}

extension PView_peak: LabelSetDelegate {
    
    func didDoubleTap(at pType: ParameterType) {
        if pType == .x {
            print("freq doubleTapped at index \(index)")
            delegate?.didDoubleTap_freq(at: index)
            updateXLabel()
        } else if pType == .y {
            print("gain doubleTapped at index \(index)")
            delegate?.didDoubleTap_gain(at: index)
            updateYLabel()
        } else if pType == .z {
            print("Q doubleTapped at index \(index)")
            delegate?.didDoubleTap_Q(at: index)
            updateZLabel()
        }
    }
}
