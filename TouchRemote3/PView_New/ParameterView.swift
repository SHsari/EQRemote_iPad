//
//  ParameterView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/15/24.
//


import UIKit


let pViewDict: [FilterType : () -> ParameterView] = [
    .peak: { PView_withSlider() },
    .lowPass: { PView_noSlider() },
    .highPass: { PView_noSlider() },
    .lowShelf: { PView_withSlider() },
    .highShelf: { PView_withSlider() }
]


protocol PViewDelegate: MainViewController {
    func sliderTouchesBegan(_ index: Int)
    func sliderMoved(_ value: Double)
    func sliderTouchesEnded()
    func xLocktoggled(at index: Int)
    func yLocktoggled(at index: Int)
    
    func didDoubleTap_freq(at index: Int)
    func didDoubleTap_gain(at index: Int)
    func didDoubleTap_Q(at index: Int)
    
    func copyRequest(at index: Int, pType: ParameterType)
    func pasteRequest(at index: Int)
    func typeInRequest(at index: Int, type: ParameterType)
}


protocol ParameterView: UIView {
    var index: Int { get set }
    var delegate: PViewDelegate? { get set }
    func initialize(_ position: XYZPosition, _ index: Int, _ delegate: PViewDelegate)
    func setLayoutWithSuperView()
    func updateXLabel()
    func updateYLabel()
    func updateZLabel()
    func updateSlider(_ value: Double)
    func updateWhole(_ slider: Double)
    func setViewActive(_ isActive: Bool)
}


class PViewClass: UIStackView, ParameterTypeConfigurable {
    
    var index: Int = -1
    weak var delegate: PViewDelegate?
    internal var bind = XYZPosition()
    internal var pType: ParameterType = .band
       
    func initialize(_ position: XYZPosition, _ index: Int, _ delegate: PViewDelegate) {
        
        self.bind = position
        self.index = index
        self.delegate = delegate
        
        self.axis = .vertical
        self.distribution = .fillEqually
        self.alignment = .center
        self.spacing = 0
        
        setLayoutWithSuperView()
    }
    
    internal func setLayoutWithSuperView() {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    func setViewActive(_ isActive: Bool) {
        self.alpha = isActive ? 1.0 : 0.5
        isUserInteractionEnabled = isActive
    }
}


extension PViewClass: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let hitView = self.hitTest(location, with: nil)
        if hitView is UIButton {
            print("hitView is UIButton")
            return nil
        }
        
        guard let pTypeConfigurable = interaction.view as? ParameterTypeConfigurable else { return nil }
        let pType = pTypeConfigurable.pType
        let titleString = "band \(self.index + 1): " + pTypeStringDict[pType]!
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            var actions: [UIAction] = []
            
            let copyAction = UIAction(title: "copy", image: UIImage(systemName: "doc.on.doc")) { action in
                Clipboard.type = pType
                Clipboard.index = self.index
                self.delegate?.copyRequest(at: self.index, pType: pType)
            }; actions.append(copyAction)
            
            if let ctype = Clipboard.type, ctype == pType {
                let pasteAction = UIAction(title: "paste", image: UIImage(systemName: "doc.on.clipboard")) { action in
                    self.delegate?.pasteRequest(at: self.index)
                }
                actions.append(pasteAction)
            }
           
            if pType == .band {
                let typeAction = UIAction(title: "type in", image: nil) { action in
                    self.delegate?.typeInRequest(at: self.index, type: pType)
                }; actions.append(typeAction)
            }
            return UIMenu(title: titleString, children: actions)
        })
    }
}


