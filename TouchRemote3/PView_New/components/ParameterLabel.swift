//
//  ParameterLable.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/29/24.
//

import UIKit

protocol ParameterLabelDelegate: ParameterView {
    func labelDidDoubleTap(at pType: ParameterType)
    func labelDidLongPress(at pType: ParameterType)
}


class ParameterLabel: UILabel {
    
    var delegate: ParameterLabelDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGestures() {
        let doubleTapRECG = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRECG.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapRECG)
        
        let longPressRECG = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressRECG)
    }
    
    // 더블 탭 처리
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        //delegate?.labelDidDoubleTap(at: pType)
    }
    
    // 길게 누르기 처리
    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {  // 터치가 시작될 때만 반응
            //delegate?.labelDidLongPress(at: pType)
        }
    }
}
