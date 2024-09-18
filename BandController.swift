//
//  BandController.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/18/24.
//
/*
import Foundation

class BandParameterCenter: RespCalculatorDelegate {
    
    var valueBinder: ValueSwitcher
    var filter: EQfilter
    private var response: ResponseLeaf
    
    var normX: Double
    var normY: Double
    var normZ: Double
    
    var bindX: Double
    var bindY: Double
    var bindZ: Double
    
    var type: FilterType
    var isOn: Bool
    
    var delegatePView: PCenterDelegate_PView?
    var delegateTouchMeDot: PCenterDelegate_TouchMeDot?
    var delegateGraphLayer: PCenterDelegate_GraphLayer?
    
    func setNormXY(_ normX: Double, _ normY: Double) {
        self.normX = normX
        self.normY = normY
        bindX = valueBinder.getBindX(normX)
        bindY = valueBinder.getBindY(normY)
        delegatePView?.setXYLabel(bindX, bindY)
        calculator.setX()
        calculator.setY()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }
    
    func setNormX(_ normX: Double) {
        self.normX = normX
        bindX = valueBinder.getBindX(normX)
        calculator.setX()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }
    
    func setNormY(_ normY: Double) {
        self.normY = normY
        bindY = valueBinder.getBindY(normY)
        calculator.setY()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }
    
    func setNormZ(_ normZ: Double) {
        self.normZ = normZ
        bindZ = valueBinder.getBindZ(normZ)
        calculator.setZ()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }
    
    func setBindX(_ bindX : Double) {
        self.bindX = bindX
        normX = valueBinder.getNormX(bindX)
        calculator.setX()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }
    
    func setBindY(_ bindY : Double) {
        self.bindY = bindY
        normY = valueBinder.getNormY(bindY)
        calculator.setY()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }

    func setBindZ(_ bindZ : Double) {
        self.bindZ = bindZ
        normZ = valueBinder.getNormZ(bindZ)
        calculator.setZ()
        calculator.updateResponse()
        delegateGraphLayer?.updateGraph()
    }
    
    func setOnOff(at index: Int, isOn: Bool) {
        self.isOn = isOn
        delegatePView?.setViewActive(isOn)
        delegateTouchMeDot?.setDotActive(isOn)
        if !isOn { response.setResponseDefault() }
        else { calculator.updateResponse() }
    }
    
    func getBandInfo() -> OneBand {
        let position = XYZPosition(x: normX, y: normY, z: normZ)
        return OneBand(type, position, isOn)
    }
    
    init(_ band: OneBand, _ response: ResponseLeaf) {
        self.index = index
        let position = band.position
        isOn = band.isOn
        type = band.type
        valueBinder = BandParameterCenter.typeValueBinderDict[type]!
        normX = position.x
        normY = position.y
        normZ = position.z
        bindX = valueBinder.getBindX(normX)
        bindY = valueBinder.getBindY(normY)
        bindZ = valueBinder.getBindZ(normZ)
        self.response = response
        calculator = BandParameterCenter.typeCalculatorDict[type]?(response) ?? Peak(response)
        calculator.delegateInitializer(self)
    }
    
    static let typeValueBinderDict: [FilterType : ValueSwitcher] = [
        .peak: PeakSwitcher(),
        .lowPass: PassSwitcher(),
        .highPass: PassSwitcher(),
        .lowShelf: ShelfSwitcher(),
        .highShelf: ShelfSwitcher()
    ]
    static let typeCalculatorDict: [FilterType : ((ResponseLeaf) -> ResponseCalculator)] = [
        .peak: {response in Peak(response)},
        .lowPass: {response in LowPass(response)},
        .highPass: {response in HighPass(response)},
        .lowShelf: {response in LowShelf(response)},
        .highShelf: {response in HighShelf(response)}
    ]
}

protocol ValueSwitcher {
    func getBindX(_ normX: Double) -> Double
    func getBindY(_ normY: Double) -> Double
    func getBindZ(_ normZ: Double) -> Double
    func getNormX(_ bindX: Double) -> Double
    func getNormY(_ bindY: Double) -> Double
    func getNormZ(_ bindZ: Double) -> Double
}

class PeakSwitcher: ValueSwitcher {
    func getBindX(_ normX: Double) -> Double { return Calculate.frequency(normX) }
    func getBindY(_ normY: Double) -> Double { return Calculate.gain(normY) }
    func getBindZ(_ normZ: Double) -> Double { return Calculate.peakQ(normZ) }
    func getNormX(_ bindX: Double) -> Double { return Calculate.normX(bindX) }
    func getNormY(_ bindY: Double) -> Double { return Calculate.normYwith(gain: bindY) }
    func getNormZ(_ bindZ: Double) -> Double { return Calculate.normZwith(peakQ: bindZ) }
}

class PassSwitcher: ValueSwitcher {
    func getBindX(_ normX: Double) -> Double { return Calculate.frequency(normX) }
    func getBindY(_ normY: Double) -> Double { return Calculate.passQ(normY) }
    func getBindZ(_ normZ: Double) -> Double { return 0 }
    func getNormX(_ bindX: Double) -> Double { return Calculate.normX(bindX) }
    func getNormY(_ bindY: Double) -> Double { return Calculate.normYwith(passQ: bindY) }
    func getNormZ(_ bindZ: Double) -> Double { return 0 }
}

class ShelfSwitcher: ValueSwitcher {
    func getBindX(_ normX: Double) -> Double { return Calculate.frequency(normX) }
    func getBindY(_ normY: Double) -> Double { return Calculate.gain(normY) }
    func getBindZ(_ normZ: Double) -> Double { return Calculate.shelfQ(normZ) }
    func getNormX(_ bindX: Double) -> Double { return Calculate.normX(bindX) }
    func getNormY(_ bindY: Double) -> Double { return Calculate.normYwith(gain: bindY) }
    func getNormZ(_ bindZ: Double) -> Double { return Calculate.normZwith(peakQ: bindZ) }
}*/



