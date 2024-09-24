//
//  ParameterLabelButton.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/23/24.
//

import UIKit

class CustomButtonLabel: UIButton {
    var firstLabel = UILabel()
    var secondLabel = UILabel()
    var title = "Hello"
    var message = "Enter text"
    var placeHolder = "placeHolder"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabels()
    }
    
    private func setupLabels() {
        firstLabel.text = "Label_1"
        firstLabel.font = UIFont.systemFont(ofSize: 17)
        firstLabel.textAlignment = .right
        
        secondLabel.text = "Label_2"
        secondLabel.font = UIFont.systemFont(ofSize: 15)
        
        addSubview(firstLabel)
        addSubview(secondLabel)
        
        NSLayoutConstraint.activate([
            
            secondLabel.leadingAnchor.constraint(equalTo: centerXAnchor),
            firstLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -20),
            
        ])
    }
    @objc func buttonTapped() {
        let alertController = UIAlertController(title: "Update Label", message: "Enter new text", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "New text here"
            }
            let confirmAction = UIAlertAction(title: "OK", style: .default) { [unowned alertController] _ in
                let textField = alertController.textFields![0]
                self.firstLabel.text = textField.text
            }
            alertController.addAction(confirmAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

