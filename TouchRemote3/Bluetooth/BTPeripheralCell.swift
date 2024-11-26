//
//  BTPeripheralCell.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 10/18/24.
//

import UIKit

class RssiView: UIView {
    
    var l1 = CAShapeLayer()
    var l2 = CAShapeLayer()
    var l3 = CAShapeLayer()
    var l4 = CAShapeLayer()
    
    var bars: [CAShapeLayer] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        self.bars = [l1, l2, l3, l4]
        let barWidth = bounds.width / 4
        let lineWidth = bounds.width / 7
        let stepLength = bounds.height / 4
        
        for (i, bar) in bars.enumerated() {
            let barHeight = stepLength * CGFloat(i+1)
            let xPosition = CGFloat(i) * barWidth
            let bezierPath = UIBezierPath(rect: CGRect(x: xPosition, y: bounds.height-barHeight, width: lineWidth, height: barHeight))
            bar.path = bezierPath.cgPath
            bar.lineWidth = 0; bar.opacity = 0.9
            self.layer.addSublayer(bar)
        }
    }
    
    func setStrength(rssi: NSNumber) {
        self.backgroundColor = .clear
        let rssi_int = Int(truncating: rssi)
        let strength: Int
        switch rssi_int {
        case ..<(-120): strength = 0
        case ..<(-90): strength = 1
        case ..<(-75): strength = 2
        case ..<(-55): strength = 3
        default: strength = 4
        }
        
        for (i, bar) in bars.enumerated() {
            if i < strength {
                bar.fillColor = UIColor.label.cgColor
            } else { bar.fillColor = UIColor.tertiaryLabel.cgColor }
        }
    }
}

class BTPeripheralCell: UITableViewCell {
    
    @IBOutlet weak var PeripheralName: UILabel!
    @IBOutlet weak var rssiIndicator: RssiView!
    @IBOutlet weak var connected: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        connected.isHidden = true
        checkmark.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if connected.isHidden {
            super.setSelected(selected, animated: animated)
        }
    }
    
    func setStrength(rssi: NSNumber) {
        rssiIndicator.setStrength(rssi: rssi)
    }
    
    func setConnected(_ isConnected: Bool) {
        checkmark.isHidden = !isConnected
    }
    
}
