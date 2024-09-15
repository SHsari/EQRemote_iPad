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

fileprivate let normX1 = freqToNormPos(freq: freqDict1)
fileprivate  let normX2 = freqToNormPos(freq: freqDict2)

class GridView: UIView {
    var standardFrame: CGRect
    
    init(frame: CGRect, standard: CGRect) {
        self.standardFrame = standard
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
        drawGridLines(in: context, yLines: 5)
    }
    

    private func drawGridLines(in context: CGContext, yLines: Int) {
        let rect = standardFrame
        context.setStrokeColor(UIColor.white.cgColor)
        
        context.setLineWidth(1)
        context.setAlpha(0.2)
        // 수평 그리드 라인
        let horizontalSpacing = rect.height / CGFloat(yLines + 1)
        var y = CGFloat(0.0)
        for _ in 1...yLines+3 {
            y += horizontalSpacing
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        // 수직 그리드 라인
        for normX in normX1 {
            let x = normX * rect.width
            context.move(to: CGPoint(x: x, y: 0.0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        context.strokePath()
        
        // 100, 1000, 10000 수직 그리드
        context.setAlpha(0.3)
        for normX in normX2 {
            let x = normX * rect.width
            context.move(to: CGPoint(x: x, y: 0.0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        context.strokePath()
    }
}
