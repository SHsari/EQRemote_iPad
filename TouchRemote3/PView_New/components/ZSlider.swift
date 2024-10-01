//
//  zSlider.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/28/24.
//

import UIKit


protocol ZSliderDelegate: ParameterView {
    func sliderDidDoubleTap()
}

class ZSlider: UISlider {
    var type: ParameterType = .z
    var delegate: ZSliderDelegate?

    func addDoubleTap() {
        let doubleTapRecg = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecg.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecg)
    }
    
    @objc func handleDoubleTap() {
        delegate?.sliderDidDoubleTap()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        maximumValue = 1.0
        minimumValue = 0.0
        value = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
