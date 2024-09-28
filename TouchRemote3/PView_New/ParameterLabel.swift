//
//  ParameterLab.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/26/24.
//

import UIKit

protocol ParameterLabelDelegate: Any {
    func labelDidDoubleTap(which label: ParameterLabel)
    func labelDidLongPress(which label: ParameterLabel)
}

class ParameterLabel: UILabel {
    
    weak var delegate: ParameterLabelDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.isUserInteractionEnabled = true  // 사용자 상호작용 활성화
        
        // 더블 탭 제스처 인식기 추가
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapRecognizer)
        
        // 길게 누르기 제스처 인식기 추가
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    // 더블 탭 처리
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        print("Double tapped on label")
        // 여기에 더블 탭시 실행할 로직을 추가합니다.
        delegate?.labelDidDoubleTap(which: self)
    }
    
    // 길게 누르기 처리
    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {  // 터치가 시작될 때만 반응
            print("Long pressed on label")
            // 여기에 길게 누를 때 실행할 로직을 추가합니다.
            delegate?.labelDidLongPress(which: self)
        }
    }
}
