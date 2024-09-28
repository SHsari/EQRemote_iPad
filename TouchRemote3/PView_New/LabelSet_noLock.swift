//
//  File.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/26/24.
//

import Foundation
import UIKit

enum LabelType {
    case frequency
    case passQ
    case gain
    case sliderQ
}
let mainFont = UIFont.systemFont(ofSize: 17)
let secondFont = UIFont.systemFont(ofSize: 15)

let labelTypeDict: [LabelType : () -> Void] = [:]


class LabelSet_noLock: UIView {
    
    var mainLabel: ParameterLabel
    var secondLabel: UILabel
    
    func setViewActive(_ isActive: Bool) {
        mainLabel.isUserInteractionEnabled = isActive
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mainLabel = ParameterLabel(frame: .zero)
        self.mainLabel.font = mainFont
        self.mainLabel.textAlignment = .left
        self.secondLabel = UILabel(frame: .zero)
        self.secondLabel.font = secondFont
        self.secondLabel.textAlignment = .right
        addSubview(mainLabel)
        addSubview(secondLabel)
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
        
        mainLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        secondLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        secondLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -20),
        
        NSLayoutConstraint(item: secondLabel, attribute: .right, relatedBy: .equal, toItem: mainLabel, attribute: .left, multiplier: 1.0, constant: -10)
        ])
    }
}
