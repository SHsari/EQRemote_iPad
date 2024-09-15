//
//  BluetoothSerial.swift
//  TouchRemote
//
//  Created by Seokhyun Song on 8/4/24.
//

import CoreBluetooth

let fb301CharisticUUID = CBUUID(string: "FFF1")
let fb301ServiceUUID = CBUUID(string: "FFF0")
let hm10ServiceUUID = CBUUID(string: "FFE0")
let hm10CharacteristicUUID = CBUUID(string: "FFE1")

let serviceUUIDArray = [fb301ServiceUUID, hm10ServiceUUID]
let characteristicUUIDArray = [fb301CharisticUUID, hm10CharacteristicUUID]

protocol BluetoothSerialDelegate: BluetoothVC {
    func didDiscoverNewPeripheral()
    func bluetoothConnected()
    func btWriteFailed()
    func btDisconnectionHandler(error: (any Error)?)
}

struct PeripheralInfo {
    var peripheral: CBPeripheral
    var rssi: NSNumber
}

class BluetoothSerial: NSObject {
    
    var numberOfsuccess = 0
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [PeripheralInfo] = []
    weak var delegate: BluetoothSerialDelegate?
    
    var connectedPeripheral: CBPeripheral?
    var serialWriteCharistic: CBCharacteristic?
    var serialService: CBService?
    var pioService: CBService?
    var pioOutputCharistic: CBCharacteristic?
    var pendingData = Data()
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
        pendingData = data
        print("dataLength: \(data) ")
        connectedPeripheral?.writeValue(data, for: serialWriteCharistic!, type: .withResponse)
    }
    
}


extension BluetoothSerial: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on.")
            // 스캔 시작: 서비스 UUIDs를 nil로 설정하면 모든 디바이스를 스캔
            centralManager.scanForPeripherals(withServices: serviceUUIDArray , options: nil)
        default: return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let newPeripheralInfo = PeripheralInfo(peripheral: peripheral, rssi: RSSI)
        if !discoveredPeripherals.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(newPeripheralInfo)
            //discoveredPeripherals.sort { $0.rssi.intValue > $1.rssi.intValue }
            delegate?.didDiscoverNewPeripheral()
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
                print("characteristic Found!")
                self.serialWriteCharistic = characteristic
                centralManager.stopScan()
                
                let length = peripheral.maximumWriteValueLength(for: .withResponse)
                print("maximumWriteValueLength: \(length) Byte")
                break
            }
        }
        delegate?.bluetoothConnected()
    }

    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if error == nil {
            repeating = 0
            //numberOfsuccess += 1
            //print("success: \(numberOfsuccess)")
        }
        else if repeating < 5 {
            peripheral.writeValue(pendingData, for: serialWriteCharistic!, type: .withResponse)
            repeating += 1
            print("repeating")
        }
        else {
            print("failed")
            repeating = 0
            print("Write failed with error: \(error!.localizedDescription)")
            delegate?.btWriteFailed()
        }
    }
}
