//
//  LabelSet_freq.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/26/24.
//

import UIKit

class LabelSet_withLock: UIView {
    
    var lockButton = LockButton(frame: .zero, isLocked: false)
    var mainLabel: ParameterLabel
    var secondLabel: UILabel
    
    func setViewActive(_ isActive: Bool) {
        mainLabel.isUserInteractionEnabled = isActive
        lockButton.isEnabled = isActive
    }
    
    override init(frame: CGRect) {
        self.mainLabel = ParameterLabel(frame: .zero)
        self.mainLabel.font = mainFont
        self.mainLabel.textAlignment = .right
        self.secondLabel = UILabel(frame: .zero)
        self.secondLabel.font = secondFont
        self.secondLabel.textAlignment = .left
        mainLabel.textAlignment = .right
        secondLabel.textAlignment = .left
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
        mainLabel.widthAnchor.constraint(equalToConstant: 52),
        mainLabel.heightAnchor.constraint(equalToConstant: 21),
        secondLabel.widthAnchor.constraint(equalToConstant: 19),
        secondLabel.heightAnchor.constraint(equalToConstant: 20),
        lockButton.widthAnchor.constraint(equalToConstant: 42),
        lockButton.heightAnchor.constraint(equalToConstant: 32),
        
        mainLabel.centerYAnchor.constraint(equalTo: super.centerYAnchor),
        secondLabel.centerYAnchor.constraint(equalTo: super.centerYAnchor),
        lockButton.centerYAnchor.constraint(equalTo: super.centerYAnchor),
        
        secondLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 15),
        
        NSLayoutConstraint(item: secondLabel, attribute: .left, relatedBy: .equal, toItem: mainLabel, attribute: .right, multiplier: 1.0, constant: 10),
        
        NSLayoutConstraint(item: secondLabel, attribute: .right, relatedBy: .equal, toItem: lockButton, attribute: .left, multiplier: 1.0, constant: 0)
        ])
    }
}
