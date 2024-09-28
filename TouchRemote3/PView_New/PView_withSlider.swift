//
//  PView_withSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/27/24.
//

import UIKit

//
//  PView_noSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/27/24.
//

import UIKit

class PView_withSlider_new: PViewClass {
    
    weak var delegate_: ParameterView_D?
    
    let freqView: LabelSet_withLock
    let gainView: LabelSet_withLock
    let QView: LabelSet_noLock
    
    var freqLabel: ParameterLabel
    var gainLabel: ParameterLabel
    var QLabel: ParameterLabel
    var xLock: LockButton
    var yLock: LockButton
    var QSlider: ZSlider
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .center
        self.spacing = 0
        
        freqView = LabelSet_withLock()
        gainView = LabelSet_withLock()
        QView = LabelSet_noLock()
        QSlider = ZSlider()
        freqLabel = freqView.mainLabel
        gainLabel = gainView.mainLabel
        QLabel = QView.mainLabel
        xLock = freqView.lockButton
        yLock = freqView.lockButton
        freqLabel.delegate = self
        gainLabel.delegate = self
        QLabel.delegate = self
        freqView.secondLabel.text = "Hz"
        gainView.secondLabel.text = "dB"
        QView.secondLabel.text = "Q"
        setupLayout()
        setupActions()
    }
    
    required init(coder: NSCoder) {
        fatalError("withSlider Loading")
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
        
        QSlider.widthAnchor.constraint(equalTo: <#T##NSLayoutDimension#>, multiplier: <#T##CGFloat#>)
        
        addArrangedSubview(stackView1)
        addArrangedSubview(QSlider)
        addArrangedSubview(QView)
    }
    
    private func setupActions() {
        xLock.addTarget(self, action: #selector(xLockToggled), for: .touchUpInside)
        yLock.addTarget(self, action: #selector(yLockToggled), for: .touchUpInside)
        QSlider.addTarget(self, action: #selector(sliderTouchesBegan), for: .touchDown)
        QSlider.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        QSlider.addTarget(self, action: #selector(sliderTouchesEnded), for: .touchUpInside)
    }
    @objc private func xLockToggled() { delegate?.xLocktoggled(at: index) }
    @objc private func yLockToggled() { delegate?.yLocktoggled(at: index) }
    @objc private func sliderTouchesBegan() { delegate?.sliderTouchesBegan(index)}
    @objc private func sliderMoved() { delegate?.sliderMoved(Double(QSlider.value))}
    @objc private func sliderTouchesEnded() {delegate?.sliderTouchesEnded()}
}

extension PView_withSlider_new: ParameterView {
    
    func updateXLabel() { freqLabel.text = String(format: "%.0f", bind.x) }
    
    func updateYLabel() { gainLabel.text = String(format: "%.0f", bind.y) }
    
    func updateZLabel() { QLabel.text = String(format: "%.0f", bind.z) }
    
    func updateSlider(_ z: Double) {}
    
    func setViewActive(_ isActive: Bool) {
        self.alpha = isActive ? 1.0 : 0.5
        freqView.setViewActive(isActive)
        gainView.setViewActive(isActive)
    }
}

extension PView_withSlider_new: ParameterLabelDelegate {
    func labelDidDoubleTap(which label: ParameterLabel) {
        if label == freqLabel {
            delegate_?.didDoubleTap_freq(at: index)
        } else if label == gainLabel {
            delegate_?.didDoubleTap_gain(at: index)
        } else if label == QLabel {
            delegate_?.didDoubleTap_Q(at: index)
        }
    }
    
    func labelDidLongPress(which label: ParameterLabel) {
        if label == freqLabel {
            delegate_?.didLongPress_freq(at: index)
        } else if label ==  gainLabel {
            delegate_?.didLongPress_gain(at: index)
        } else if label == QLabel {
            delegate_?.didDoubleTap_Q(at: index)
        }

    }
}

