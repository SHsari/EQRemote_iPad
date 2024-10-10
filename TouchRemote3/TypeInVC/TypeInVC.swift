//
//  TypeinVC.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 10/7/24.
//

import UIKit

protocol TypeInVCDelegate: MainViewController {
    func vcDismissed(at index: Int, _ values: [Double?])
}

class TypeInVC: UIViewController {

    var activeLabel: TypeInLabel?
    var bufferStr: String = ""
    lazy var index: Int = -1
    weak var mainVC: TypeInVCDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var oldX: UILabel!
    @IBOutlet weak var oldY: UILabel!
    @IBOutlet weak var oldZ: UILabel!

    @IBOutlet weak var newX: TypeInLabel!
    @IBOutlet weak var newY: TypeInLabel!
    @IBOutlet weak var newZ: TypeInLabel!
    
    lazy var typeLabels: [TypeInLabel] = [newX, newY, newZ]
    
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var switch3: UISwitch!
    
    lazy var switches: [UISwitch] = [switch1, switch2, switch3]
    @IBOutlet weak var stackView1: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func switchesToggled(_ sender: UISwitch) {
        if sender.isOn {
            activeLabel = typeLabels[sender.tag]
            verify()
        }
    }

    @IBAction func numberPad(_ sender: UIButton) {
        guard let activeLabel = activeLabel else { return }
        activeLabel.append(char: sender.titleLabel!.text!)
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        guard let activeLabel = activeLabel, let text = activeLabel.text,
              text.count > 0 else { return }
        activeLabel.text = String(text.dropLast(1))
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        guard let activeLabel = activeLabel else { return }
        activeLabel.text = ""
        verify()
    }
    
    @IBAction func verifyButton(_ sender: UIButton) {
        verify()
    }
    
    @IBAction func applyButton(_ sender: UIButton) {
        viewWillDismiss(isApplying: true)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        viewWillDismiss(isApplying: false)
        dismiss(animated: true)
    }
    
    private func verify() {
        guard let activeLabel = activeLabel else { return }
        let value = activeLabel.verify()
        if value == nil { switches[activeLabel.tag].isOn = false }
        else {
            switches[activeLabel.tag].isOn = true
            activeLabel.setInactive()
        }
    }
    
    
    func initialize(index: Int, band: OneBand, delegate: TypeInVCDelegate) {
        self.index = index
        mainVC = delegate
        let type = band.type
        let position = band.position
        oldX.text = String(format: "%.1f", position.x)
        oldY.text = String(format: "%.2f", position.y)
        oldZ.text = String(format: "%.2f", position.z)
        
        titleLabel.text = "band_\(index)  .\(typeStringDict[type]!)"
        
        newX.initialize(min: 20, max: 20000)
        newY.initialize(min: -18, max: 18)
        
        setActions()
        
        if type == .lowPass || type == .highPass {
            newZ.text = " - "
            newZ.gestureRecognizers?.removeFirst()
            newZ.isUserInteractionEnabled = false
            newZ.alpha = 0.5
            switch3.isUserInteractionEnabled = false
            switch3.alpha = 0.5
        } else if type == .peak {
            newZ.initialize(min: 0.1, max: 32.0)
        } else {
            newZ.initialize(min: 0.4, max: 4.0)
        }
    }
    
    
    private func setActions() {
        [newX, newY, newZ].forEach { label in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapHandler))
            label?.addGestureRecognizer(tapGesture)
            label?.isUserInteractionEnabled = true
        }
    }
    
    @objc private func labelTapHandler(_ sender: UITapGestureRecognizer) {
        guard let tappedLabel = sender.view as? TypeInLabel else { return }
        verify()
        activeLabel?.setInactive()
        if tappedLabel == activeLabel {
            activeLabel = nil
        } else {
            tappedLabel.setActive()
            activeLabel = tappedLabel
        }
    }
    
    private func viewWillDismiss(isApplying: Bool) {
        var xyzEnabled: [Bool] = []
        var xyzValue: [Double?] = []
        if isApplying {
            for switch_ in switches {
                xyzEnabled.append(switch_.isOn)
            }
            for label in typeLabels {
                xyzValue.append(label.value)
            }
            mainVC?.vcDismissed(at: index, xyzValue)
        }
    }

    
    
}
