//
//  BluetoothDataMaker.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/20/24.
//

import Foundation

class BluetoothDataSender {
    
    private let typeNumberDict: [FilterType : UInt8] = [
        .peak: UInt8(0b00000001),
        .lowPass: UInt8(0b00000010),
        .highPass: UInt8(0b00000011),
        .lowShelf: UInt8(0b00000100),
        .highShelf: UInt8(0b00000101)
    ]

    private let boolToData: [Bool : UInt8] = [
        true: UInt8(0b00001111),
        false: UInt8(0b00001000)
    ]
    
    private let sendInterval = 2
    
    var serial: BluetoothSerial?
    let positionData = UInt8(0b11100000)
    let xData = UInt8(0b00010000)
    let yData = UInt8(0b00100000)
    let zData = UInt8(0b00110000)
    let onOffData = UInt8(0b01000000)
    let bandData = UInt8(0b01010000)
    
    var pendingData: [Data] = []
    var intervalCount = 0
    var count = 0
    var activeIndex: Int = -1
    
    var storage: [OneBand] = []
    var bind: [XYZPosition] = []
    
    init(storage: [OneBand], bind: [XYZPosition]) {
        self.storage = storage
        self.bind = bind
    }
    
    private func doubleToFloatData(_ value: Double) -> Data {
        var x = Float(value)
        let bytes =  withUnsafeBytes(of: &x) { Data($0) }
        return Data(bytes)
    }
    
    func willSendData(at index: Int) {
        activeIndex = index
    }
    
    func sendLastZData() {
        isSendingZ = false
        intervalCount = 0
        var data = Data()
        let firstByte = zData | UInt8(activeIndex)
        data.append(firstByte)
        data.append(doubleToFloatData(bind[activeIndex].z))
        serial?.sendDataToHW_should(data, at: activeIndex)
    }
    func sendLastXYData() {
        isSendingXY = false
        intervalCount = 0
        var data = Data()
        let firstByte = positionData | UInt8(activeIndex)
        data.append(firstByte)
        data.append(doubleToFloatData(bind[activeIndex].x))
        data.append(doubleToFloatData(bind[activeIndex].y))
        serial?.sendDataToHW(data)
    }
    
    func sendXYdata(xy: XYPosition) {
        guard let serial = serial else { return }
        let index = activeIndex
        if intervalCount >= sendInterval {
            intervalCount = 0
            var data = Data()
            let firstByte = positionData | UInt8(index)
            data.append(firstByte)
            data.append(doubleToFloatData(xy.x))
            data.append(doubleToFloatData(xy.y))
            serial.sendDataToHW(data)
        } else { intervalCount += 1 }
    }
    
    func sendZdata(z: Double) {
        guard let serial = serial else { return }
        let index = activeIndex
        if intervalCount == sendInterval {
            intervalCount = 0
            var data = Data()
            let firstByte = zData | UInt8(index)
            data.append(firstByte)
            data.append(doubleToFloatData(z))
            serial.sendDataToHW(data)
        } else { intervalCount += 1 }
    }
    
    func sendOnOffData(at index: Int, isOn: Bool) {
        guard let serial = serial else { return }
        var data = Data()
        let firstByte = onOffData | UInt8(index)
        data.append(firstByte)
        let typeByte = boolToData[isOn]!
        data.append(typeByte)
        serial.sendDataToHW_should(data, at: index)
    }
    
    func sendBandData(at index: Int, band: OneBand) {
        guard let serial = serial else { return }
        var data = Data()
        let firstByte = bandData | UInt8(index)
        data.append(firstByte)
        let typeByte = typeNumberDict[band.type]!
        data.append(typeByte)
        let position = band.position
        data.append(doubleToFloatData(position.x))
        data.append(doubleToFloatData(position.y))
        data.append(doubleToFloatData(position.z))
        
        serial.sendDataToHW_should(data, at: index)
        //print("dataLength: \(data.count) byte ")
    }
    
    func resetAllData(preset: [OneBand]) {
        for (i, band) in preset.enumerated() {
            sendBandData(at: i, band: band)
        }
    }
    
    func test() {
        guard let serial = serial else {return}
        var data = Data()
        let bytes = UInt8(15)
        for _ in 0...63 {
            data.append(bytes)
            //print("dataLength: \(data.count) bytes")
            serial.sendDataToHW(data)
        }
    }
}
