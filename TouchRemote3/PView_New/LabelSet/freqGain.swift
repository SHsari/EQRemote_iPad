//
//  FreqLabel.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 10/1/24.
//

import UIKit

class LabelSet_freq: LabelSet {
    var lockButton = LockButton(frame: .zero, isLocked: false)
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pType = .x
        self.mainLabel.font = mainFont
        self.mainLabel.textAlignment = .right
        secondLabel.text = "Hz"
        self.secondLabel.font = secondFont
        self.secondLabel.textAlignment = .right
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func commonInit() {
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainLabel)
        addSubview(secondLabel)
        addSubview(lockButton)

        NSLayoutConstraint.activate([
        mainLabel.widthAnchor.constraint(equalToConstant: 52),
        mainLabel.heightAnchor.constraint(equalToConstant: 21),
        mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        mainLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        
        secondLabel.widthAnchor.constraint(equalToConstant: 28),
        secondLabel.heightAnchor.constraint(equalToConstant: 20),
        secondLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        secondLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor),
        
        lockButton.widthAnchor.constraint(equalToConstant: 42),
        lockButton.heightAnchor.constraint(equalToConstant: 32),
        lockButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        lockButton.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant: 4)
        ])
    }
}



class LabelSet_gain: LabelSet {
    var lockButton = LockButton(frame: .zero, isLocked: false)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.pType = .y
        lockButton.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.textAlignment = .right
        secondLabel.textAlignment = .right
        secondLabel.text = "dB"
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainLabel)
        addSubview(secondLabel)
        addSubview(lockButton)

        NSLayoutConstraint.activate([
        mainLabel.widthAnchor.constraint(equalToConstant: 52),
        mainLabel.heightAnchor.constraint(equalToConstant: 21),
        mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        mainLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        
        secondLabel.widthAnchor.constraint(equalToConstant: 28),
        secondLabel.heightAnchor.constraint(equalToConstant: 20),
        secondLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        secondLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor),
        
        lockButton.widthAnchor.constraint(equalToConstant: 42),
        lockButton.heightAnchor.constraint(equalToConstant: 32),
        lockButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        lockButton.leadingAnchor.constraint(equalTo: secondLabel.trailingAnchor, constant: 4)
        ])
        
        if let singleTapRECG = lockButton.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer && $0.numberOfTouches == 1}) {
            self.gestureRecognizers?.first?.require(toFail: singleTapRECG)
        }
    }
}

