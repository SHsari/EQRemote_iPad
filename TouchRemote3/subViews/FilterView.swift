//
//  FilterView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//

import UIKit


let graphResolution = 2048

class FilterView: UIView {
    
    var allGraphs: [CAShapeLayer] = []
    var sectionGraphs: [CAShapeLayer] = []
    var activeLayer = CAShapeLayer()
    var activeResponse = Response()
    var rootResponse = Response()
    var xTick: Double = 0.0
    var yTick: Double = 0.0
    var yConst: Double = 0.0
    var activeIndex: Int = -1
    
    var masterLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    
    func initialize(_ rootResponse: Response) {
        let initialPath = UIBezierPath()
        initialPath.move(to: CGPoint(x: 0, y: bounds.height/2))
        initialPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height/2))
        for i in 0..<numberOfBands {
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = colorDict[i].cgColor
            shapeLayer.lineWidth = 0.7
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.path = initialPath.cgPath
            shapeLayer.zPosition = CGFloat(i % 4)
            shapeLayer.opacity = 0.7
            self.layer.addSublayer(shapeLayer)
            self.allGraphs.append(shapeLayer)
        }
        masterLayer.strokeColor = UIColor.white.cgColor
        masterLayer.lineWidth = 1.0
        masterLayer.fillColor = UIColor.clear.cgColor
        masterLayer.path = initialPath.cgPath
        masterLayer.zPosition = 1000
        self.layer.addSublayer(masterLayer)
        self.rootResponse = rootResponse
    }
    
    func setSectionActive(_ section: Int) {
        let offset = section * sectionSize
        for (i, graph) in allGraphs.enumerated() {
            graph.opacity = 0.2
            graph.zPosition = CGFloat(i % 4)
        }
        sectionGraphs = Array(allGraphs[offset..<offset+sectionSize])
        sectionGraphs.forEach{ $0.opacity = 0.7; $0.zPosition += 10}
    
    }
    
    func responseDidUpdate() {
        updatePath(activeResponse, allGraphs[activeIndex])
        updatePath(rootResponse, masterLayer)
    }
    
    func masterGraphUpdate(){
        updatePath(rootResponse, masterLayer)
    }

    private func updatePath(_ response: Response, _ layer: CAShapeLayer) {
        let response = response.dB
        let path = UIBezierPath()
        var xPosition = 0.0
        path.move(to: CGPoint(x: xPosition, y: response[0]*yTick + yConst))
        for value in response {
            xPosition += xTick
            let yPosition = value*yTick + yConst
            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
        layer.path = path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        xTick = bounds.width / Double(graphResolution)
        yTick = -bounds.height / dBRange
        yConst = bounds.height * 0.5
    }

    private func bringActiveLayerToFront() {
        let indexedZ = activeLayer.zPosition
        for layer in allGraphs {
            if indexedZ < layer.zPosition {
                layer.zPosition -= 1
            }
        }
        activeLayer.zPosition = 13
    }
}

extension FilterView {
    func setActiveIndex(_ index: Int, _ response: Response) {
        activeIndex = index
        bringActiveLayerToFront()
        activeResponse = response
    }
}
