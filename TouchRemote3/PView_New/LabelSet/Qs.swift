//
//  FreqLabel.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 10/1/24.
//

import UIKit


class LabelSet_peakQ: LabelSet {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.pType = .z
        mainLabel.textAlignment = .left
        secondLabel.textAlignment = .left
        secondLabel.text = "Q"
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainLabel)
        addSubview(secondLabel)
        
        NSLayoutConstraint.activate([
        mainLabel.widthAnchor.constraint(equalToConstant: 50),
        mainLabel.heightAnchor.constraint(equalToConstant: 21),
        mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        
        secondLabel.widthAnchor.constraint(equalToConstant: 20),
        secondLabel.heightAnchor.constraint(equalToConstant: 20),
        secondLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        secondLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -20),
        secondLabel.trailingAnchor.constraint(equalTo: mainLabel.leadingAnchor)
        ])

    }
}



class LabelSet_passQ: LabelSet {
    var lockButton = LockButton(frame: .zero, isLocked: false)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.pType = .z
        mainLabel.font = mainFont
        mainLabel.textAlignment = .left
        secondLabel.text = "Q"
        secondLabel.font = secondFont
        secondLabel.textAlignment = .left
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainLabel)
        addSubview(secondLabel)
        addSubview(lockButton)
        
        NSLayoutConstraint.activate([
        mainLabel.widthAnchor.constraint(equalToConstant: 46),
        mainLabel.heightAnchor.constraint(equalToConstant: 21),
        mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        mainLabel.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor),
        
        secondLabel.widthAnchor.constraint(equalToConstant: 20),
        secondLabel.heightAnchor.constraint(equalToConstant: 20),
        secondLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        secondLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
        
        lockButton.widthAnchor.constraint(equalToConstant: 40),
        lockButton.heightAnchor.constraint(equalToConstant: 32),
        lockButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        lockButton.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: -4)
        ])

    }
}
