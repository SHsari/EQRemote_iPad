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
    private let sendInterval = 1
    
    var serial: BluetoothSerial?
    let positionData = UInt8(0b11100000)
    let normXData = UInt8(0b00010000)
    let normYData = UInt8(0b00100000)
    let normZData = UInt8(0b00110000)
    let onOffData = UInt8(0b01000000)
    let bandData = UInt8(0b01010000)
    
    var pendingData: [Data] = []
    var intervalCount = 0
    var count = 0
    
    private func doubleToFloatData(_ value: Double) -> Data {
        var x = Float(value)
        let bytes =  withUnsafeBytes(of: &x) { Data($0) }
        return Data(bytes)
    }
    
    func sendXYdata(at index: Int, xy: XYPosition, interval: Bool = true) {
        guard let serial = serial else { return }
        if !interval || intervalCount >= sendInterval {
            count += 1
            print(count)
            intervalCount = 0
            var data = Data()
            let firstByte = positionData | UInt8(index)
            data.append(firstByte)
            data.append(doubleToFloatData(xy.x))
            data.append(doubleToFloatData(xy.y))
            serial.sendDataToHW(data)
        } else { intervalCount += 1 }
    }
    
    func sendZdata(at index: Int, z: Double, interval: Bool = true) {
        guard let serial = serial else { return }
        if !interval || intervalCount == sendInterval {
            intervalCount = 0
            var data = Data()
            let firstByte = normZData | UInt8(index)
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
        serial.sendDataToHW(data)
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
        
        serial.sendDataToHW(data)
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
