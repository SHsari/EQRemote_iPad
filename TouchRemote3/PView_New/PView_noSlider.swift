//
//  PView_noSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/27/24.
//

import UIKit

protocol ParameterView_D: MainViewController {
    func didDoubleTap_freq(at index: Int)
    func didDoubleTap_gain(at index: Int)
    func didDoubleTap_Q(at index: Int)
    func didLongPress_freq(at index: Int)
    func didLongPress_gain(at index: Int)
    func didLongPress_Q(at index: Int)
}

class PView_noSlider_new: PViewClass {
    
    weak var delegate_: ParameterView_D?
    let freqView: LabelSet_withLock
    let gainView: LabelSet_withLock
    var freqLabel: ParameterLabel
    var gainLabel: ParameterLabel
    var xLock: LockButton
    var yLock: LockButton
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .center
        self.spacing = 0
        
        freqView = LabelSet_withLock()
        gainView = LabelSet_withLock()
        freqLabel = freqView.mainLabel
        gainLabel = gainView.mainLabel
        xLock = freqView.lockButton
        yLock = freqView.lockButton
        freqLabel.delegate = self
        gainLabel.delegate = self
        freqView.secondLabel.text = "Hz"
        gainView.secondLabel.text = "dB"
        setupLayout()
        setupActions()
    }
    
    required init(coder: NSCoder) {
        fatalError("noSlider Loading")
    }
    
    private func setupLayout() {

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: super.topAnchor),
            bottomAnchor.constraint(equalTo: super.bottomAnchor),
            leadingAnchor.constraint(equalTo: super.leadingAnchor),
            trailingAnchor.constraint(equalTo: super.trailingAnchor)
        ])
        
        let stackView1 = UIStackView()
        stackView1.axis = .horizontal
        stackView1.alignment = .fill
        stackView1.distribution = .fillEqually
        
        stackView1.addArrangedSubview(freqView)
        stackView1.addArrangedSubview(gainView)
        
        addArrangedSubview(stackView1)
        addArrangedSubview(UIView())
    }
    
    private func setupActions() {
        xLock.addTarget(self, action: #selector(xLockToggled), for: .touchUpInside)
        yLock.addTarget(self, action: #selector(yLockToggled), for: .touchUpInside)
    }
    @objc private func xLockToggled() { delegate?.xLocktoggled(at: index) }
    @objc private func yLockToggled() { delegate?.yLocktoggled(at: index) }
}

extension PView_noSlider_new: ParameterView {
    
    func updateXLabel() { freqLabel.text = String(format: "%.0f", bind.x) }
    func updateYLabel() { gainLabel.text = String(format: "%.0f", bind.z) }
    func updateZLabel() {}
    func updateSlider(_ z: Double) {}
    
    func setViewActive(_ isActive: Bool) {
        self.alpha = isActive ? 1.0 : 0.5
        freqView.setViewActive(isActive)
        gainView.setViewActive(isActive)
    }
}

extension PView_noSlider_new: ParameterLabelDelegate {
    func labelDidDoubleTap(which label: ParameterLabel) {
        if label == freqLabel {
            delegate_?.didDoubleTap_freq(at: index)
        } else if label ==  gainLabel {
            delegate_?.didDoubleTap_gain(at: index)
        }
    }
    
    func labelDidLongPress(which label: ParameterLabel) {
        if label == freqLabel {
            delegate_?.didLongPress_freq(at: index)
        } else if label ==  gainLabel {
            delegate_?.didLongPress_gain(at: index)
        }

    }
}
