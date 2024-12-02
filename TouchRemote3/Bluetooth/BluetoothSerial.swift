//
//  BluetoothSerial.swift
//  TouchRemote
//
//  Created by Seokhyun Song on 8/4/24.
//

import CoreBluetooth

let fb301WriteCharUUID = CBUUID(string: "FFF1")
let fb301ReadCharUUID = CBUUID(string: "FFF2")
let fb301ServiceUUID = CBUUID(string: "FFF0")
let hm10ServiceUUID = CBUUID(string: "FFE0")
let hm10CharacteristicUUID = CBUUID(string: "FFE1")

let serviceUUIDArray = [fb301ServiceUUID, hm10ServiceUUID]
let characteristicUUIDArray = [fb301WriteCharUUID, fb301ReadCharUUID, hm10CharacteristicUUID]

protocol BluetoothSerialDelegate: BluetoothVC {
    func didDiscoverNewPeripheral(_ lastIndex: Int)
    func bluetoothConnected()
    func btWriteFailed()
    func btDisconnectionHandler(error: (any Error)?)
    func updateRssi(rssi: NSNumber, at row: Int)
    func didRemovePeripheral(at index: Int)
    func requestFromHW(command: String)
}

struct PeripheralInfo {
    var peripheral: CBPeripheral
    var rssi: NSNumber
    var lastSeen: Date
}

class BluetoothSerial: NSObject {
    
    var numberOfsuccess = 0
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [PeripheralInfo] = []
    weak var delegate: BluetoothSerialDelegate?
    
    var timer: Timer?
    
    var connectedPeripheral: CBPeripheral?
    var serialWriteCharistic: CBCharacteristic?
    var serialService: CBService?
    var pioService: CBService?
    var pioOutputCharistic: CBCharacteristic?
    var pendingData: [Data] = []
    var repeating = 0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connectToPeripheral(to pInfoIndex: Int){
        let peripheral = discoveredPeripherals[pInfoIndex].peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnectToPeripheral(){
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func sendDataToHW(_ data: Data) {
        connectedPeripheral?.writeValue(data, for: serialWriteCharistic!, type: .withResponse)
    }
    
    func sendDataToHW_should(_ data: Data, at index: Int) {
        guard let peripheral = connectedPeripheral else { return }
        pendingData.append(data)
        peripheral.writeValue(data, for: serialWriteCharistic!, type: .withResponse)
    }
    
    private func removeOutdatedPeripherals() {
        let timeout: TimeInterval = 10
        let timeout2: TimeInterval = 2
        let currentTime = Date()
        
        for (index, info) in discoveredPeripherals.enumerated() {
            if currentTime.timeIntervalSince(info.lastSeen) > timeout {
                discoveredPeripherals.remove(at: index)
                delegate?.didRemovePeripheral(at: index)
            } else if currentTime.timeIntervalSince(info.lastSeen) > timeout2 {
                let rssi = NSNumber(-150)
                discoveredPeripherals[index].rssi = NSNumber(-150)
                delegate?.updateRssi(rssi: rssi, at: index)
            }
        }
    }
    
    private func startPeripheralCleanupTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            self?.removeOutdatedPeripherals()
        }
    }
    
    private func stopTimer() {
        self.timer?.invalidate(); self.timer = nil
    }
    
    func subscribeToSerialRead(characteristic: CBCharacteristic, peripheral: CBPeripheral){
        peripheral.setNotifyValue(true, for: characteristic)
    }
}


extension BluetoothSerial: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on.")
            centralManager.scanForPeripherals(withServices: serviceUUIDArray , options: nil)
            startPeripheralCleanupTimer()
        case .poweredOff:
            print("Bluetooth is powered off.")
        default: return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let index = discoveredPeripherals.firstIndex(where: {$0.peripheral.identifier == peripheral.identifier} ) {
            discoveredPeripherals[index].rssi = RSSI
            discoveredPeripherals[index].lastSeen = Date()
            delegate?.updateRssi(rssi: RSSI, at: index)
        } else {
            let newPeripheralInfo = PeripheralInfo(peripheral: peripheral, rssi: RSSI, lastSeen: Date())
            discoveredPeripherals.append(newPeripheralInfo)
            delegate?.didDiscoverNewPeripheral(discoveredPeripherals.count - 1)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(serviceUUIDArray)
        connectedPeripheral = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
        delegate?.btDisconnectionHandler(error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        guard let services = peripheral.services else { return }
        for service in services {
            if serviceUUIDArray.contains(service.uuid) {
                print("service Found!")
                self.serialService = service
                peripheral.discoverCharacteristics(characteristicUUIDArray, for: service)
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristicUUIDArray.contains(characteristic.uuid) {
                if characteristic.uuid == fb301WriteCharUUID {
                    self.serialWriteCharistic = characteristic
                    centralManager.stopScan()
                    let length = peripheral.maximumWriteValueLength(for: .withResponse)
                    print("maximumWriteValueLength: \(length) Byte")
                    
                    stopTimer()
                    discoveredPeripherals.removeAll{ info in
                        return info.peripheral.identifier != connectedPeripheral?.identifier
                    }
                    self.centralManager.stopScan()
                    delegate?.bluetoothConnected()
                }
                else if fb301ReadCharUUID == characteristic.uuid {
                    print("characteristic for Serial Read Found!")
                    subscribeToSerialRead(characteristic: characteristic, peripheral: peripheral)
                }
            }
        }

    }

    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if !pendingData.isEmpty {
            if error == nil { pendingData.removeFirst() }
            else if repeating < 5 {
                connectedPeripheral?.writeValue(pendingData[0], for: serialWriteCharistic!, type: .withResponse)
                repeating += 1
            }
            else {
                repeating = 0
                pendingData = []
                delegate?.btWriteFailed()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiveing data:  \(error.localizedDescription)")
            return
        }
        if let data = characteristic.value {
            if let strValue = String(data: data, encoding: .utf8){
                print("Received data: \(strValue)")
                delegate?.requestFromHW(command: strValue)
            } else {
                print("Received data could not be converted to string")
            }
        }
    }
}
