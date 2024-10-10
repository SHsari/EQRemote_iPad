//
//  File.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 10/8/24.
//

import UIKit

class TypeInLabel: UILabel {
    var minValue: Double = 0.0
    var maxValue: Double = 10.0
    var value: Double?
    var format: String = "  %.2f"
    var errorStr: String = ""
    var isTyping: Bool = false
    
    func initialize(min: Double, max: Double, format: String = "  %.2f") {
        self.minValue = min
        self.maxValue = max
        errorStr = String(format: "  %.2f ~ %.2f", min, max)
        self.text = errorStr
        textColor = UIColor.secondaryLabel
        layer.borderColor = UIColor.tertiaryLabel.cgColor // 테두리 색상 설정
        layer.borderWidth = 1.0 // 테두리 두께 설정
        layer.cornerRadius = 3
        layer.masksToBounds = true // 모서리 둥글게 처리가 올바르게 적용되도록
        
    }
    
    func append(char: String) {
        if var text = text, text.count > 1, isTyping {
            self.text = text + char
        } else {
            isTyping = true
            textColor = UIColor.label
            text = "  " + char
        }
    }
    
    func verify() -> Double? {
        isTyping = false
        let number_ = Double(self.text?.dropFirst(2) ?? "")
        if var number = number_ {
            if number < minValue { number = minValue }
            else if number > maxValue { number = maxValue }
            self.value = number
            self.text = String(format: format, number)
            return number
        } else {
            self.value = nil
            self.text = errorStr
            textColor = UIColor.secondaryLabel
            return nil
        }
    }
    
    func setActive() {
        textColor = UIColor.label
        layer.borderColor = UIColor.secondaryLabel.cgColor
        
    }
    func setInactive() {
        textColor = UIColor.secondaryLabel
        layer.borderColor = UIColor.tertiaryLabel.cgColor
    }
}
