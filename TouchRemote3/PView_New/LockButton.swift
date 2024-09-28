//
//  LockButton.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/26/24.
//

import UIKit

class LockButton: UIButton {
    // 이미지 설정
    let lockedImage = UIImage(systemName: "lock.fill")
    let unlockedImage = UIImage(systemName: "lock.open")

    // 버튼의 상태를 표시하는 변수
    var isLocked: Bool = false {
        didSet {
            updateImage()
        }
    }
    
    init(frame: CGRect, isLocked: Bool) {
        self.isLocked = isLocked
        super.init(frame: frame)
        setupButton()
    }

    // 초기화 메서드
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        self.tintColor = UIColor.systemGray
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 42),
            self.heightAnchor.constraint(equalToConstant: 32)
        ])
        updateImage()
    }

    // 이미지 업데이트 함수
    private func updateImage() {
        let animationDuration = 0.3
        UIView.transition(with: self, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.setImage(self.isLocked ? self.lockedImage : self.unlockedImage, for: .normal)
            self.alpha = self.isLocked ? 1.0 : 0.2
        }, completion: nil)
    }
}
