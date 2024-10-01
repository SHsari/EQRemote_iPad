//
//  File.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/26/24.
//

import Foundation
import UIKit


let mainFont = UIFont.systemFont(ofSize: 17)
let secondFont = UIFont.systemFont(ofSize: 14)

protocol LabelSetDelegate: PViewClass {
    func didDoubleTap(at type: ParameterType)
}

class LabelSet: UIView, ParameterTypeConfigurable, UIGestureRecognizerDelegate {
    
    var delegate: LabelSetDelegate?
    var mainLabel = UILabel()
    var secondLabel = UILabel()
    
    internal var pType: ParameterType = .x
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.font = mainFont
        secondLabel.font = secondFont
        setGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewActive(_ isActive: Bool) {
        self.isUserInteractionEnabled = isActive
    }
    
    
    func setGestures() {
        let doubleTapRECG = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRECG.numberOfTapsRequired = 2
        doubleTapRECG.cancelsTouchesInView = false
        doubleTapRECG.delegate = self
        self.addGestureRecognizer(doubleTapRECG)

    }
    
    @objc internal func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didDoubleTap(at: pType)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
}
