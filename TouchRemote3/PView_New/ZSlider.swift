//
//  ZSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/28/24.
//

import UIKit

class ZSlider: UISlider {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: super.widthAnchor, multiplier: 0.8),
            centerXAnchor.constraint(equalTo: super.centerXAnchor),
            centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
