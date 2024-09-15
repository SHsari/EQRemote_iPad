//
//  FilterView.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/16/24.
//

import UIKit


let graphResolution = 2048

class FilterView: UIView {
    
    var shapeLayers: [CAShapeLayer] = []
    var layersSection1: [CAShapeLayer] = []
    var layersSection2: [CAShapeLayer] = []
    
    var masterLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initializeLayers()
        backgroundColor = .clear
    }
    
    
    private func initializeLayers() {
        let initialPath = UIBezierPath()
        initialPath.move(to: CGPoint(x: 0, y: bounds.height/2))
        initialPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height/2))
        for i in 0..<numberOfBands {
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = colorDict[i].cgColor
            shapeLayer.lineWidth = 0.7
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.path = initialPath.cgPath
            shapeLayer.zPosition = CGFloat(i)
            shapeLayer.opacity = 0.7
            self.layer.addSublayer(shapeLayer)
            self.shapeLayers.append(shapeLayer)
        }
        layersSection1 = Array(shapeLayers[0..<numberOfBands/2])
        layersSection2 = Array(shapeLayers[numberOfBands/2..<numberOfBands])
        setActiveSection(0)
        masterLayer.strokeColor = UIColor.white.cgColor
        masterLayer.lineWidth = 1.0
        masterLayer.fillColor = UIColor.clear.cgColor
        masterLayer.path = initialPath.cgPath
        masterLayer.zPosition = 1000
        self.layer.addSublayer(masterLayer)
    }
    
    func setActiveSection(_ section: Int) {
        if section == 0 {
            layersSection1.forEach{ $0.opacity = 0.7 }
            layersSection2.forEach{ $0.opacity = 0.2 }
        } else if section == 1 {
            layersSection1.forEach{ $0.opacity = 0.2 }
            layersSection2.forEach{ $0.opacity = 0.7 }
        }
    }
    
    func responseDidUpdate(at index: Int) {
        updatePath(of: shapeLayers[index], with: allResponses[index])
        bringLayerToFront(index)
    }
    
    func masterGraphUpdate() {
        updatePath(of: masterLayer, with: combinedResponse)
    }
    
    private func updatePath(of layer: CAShapeLayer, with response: Response) {
        let response = response.dB
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: (1 - (response[0]+maxdB)/(maxdB*2)) * bounds.height))
        
        for (index, value) in response.enumerated() {
            let xPosition = CGFloat(index) / CGFloat(graphResolution) * bounds.width
            let yPosition = (1 - (value+maxdB)/(maxdB*2)) * bounds.height
            
            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
        layer.path = path.cgPath
    }
    

    private func bringLayerToFront(_ index: Int) {
        guard shapeLayers.indices.contains(index) else { return }
        let indexedZ = shapeLayers[index].zPosition
        shapeLayers[index].zPosition = 4
        for layer in shapeLayers {
            if indexedZ < layer.zPosition {
                layer.zPosition -= 1
            }
        }
    }
}
