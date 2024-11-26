//
//  GridView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//

import UIKit

func freqToNormPos(freq: [Double]) -> [Double] {
    return freq.map{ (log10($0) - minLogFrequency) / logFrequencyRange }
}

fileprivate let freqDict1: [Double] = [30, 40, 50, 60, 80, 200, 300, 400, 500, 600, 800,
                          2000, 3000, 4000, 5000, 6000, 8000]
fileprivate let freqDict2: [Double] = [100, 1000, 10000]
fileprivate let dBDict: [Int] = [12, 6, 0, -6, -12]

fileprivate let normX1 = freqToNormPos(freq: freqDict1)
fileprivate let normX2 = freqToNormPos(freq: freqDict2)

class GridView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // 그리드 라인 그리기
        drawDBLines(in: context, yLines: 5)
    }
    
    func setOrientation(frame: CGRect) {
        
    }

    private func drawDBLines(in context: CGContext, yLines: Int) {
        let rect = self.bounds
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.setAlpha(0.2)
        // 수평 그리드 라인
        let horizontalSpacing = rect.height / CGFloat(yLines + 1)
        var y = CGFloat(0.0)
        for i in 0..<yLines {
            y += horizontalSpacing
            context.move(to: CGPoint(x: rect.minX , y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            
            if i < dBDict.count {
                let dBLabel = UILabel()
                dBLabel.text = String(dBDict[i])
                dBLabel.frame = CGRect(x: 0, y: y-9, width: 25, height: 20)
                dBLabel.textAlignment = .right
                dBLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
                dBLabel.textColor = UIColor.secondaryLabel
                dBLabel.backgroundColor = .systemBackground
                addSubview(dBLabel)
            }
        }
        // 수직 그리드 라인
        
        for (i, normX) in normX1.enumerated() {
            let x = normX * rect.width
            context.move(to: CGPoint(x: x, y: 0.0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
        
            setFreqLegends(freq: freqDict1[i], x: x)
        }
        context.strokePath()
        
        // 100, 1000, 10000 수직 그리드
        context.setAlpha(0.3)
        for (i, normX) in normX2.enumerated() {
            let x = normX * rect.width
            context.move(to: CGPoint(x: x, y: 0.0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
            
            setFreqLegends(freq: freqDict2[i], x: x)
        }
        context.strokePath()
        
    }
    
    private func setFreqLegends(freq: Double, x: Double) {
        let freqInt = Int(freq)
        let freqLabel = UILabel()
        let freqStr: String
        if freqInt % 1000 == 0 {
            freqStr = String(freqInt/1000) + "k"
        } else { freqStr = String(freqInt) }
        freqLabel.text = freqStr
        freqLabel.frame = CGRect(x: x-15, y: bounds.height/2+3, width: 30, height: 15)
        
        freqLabel.textAlignment = .center
        freqLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        freqLabel.textColor = UIColor.tertiaryLabel
        freqLabel.backgroundColor = .systemBackground
        addSubview(freqLabel)
    }
}
