//
//  BluetoothVC.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 8/17/24.
//


import UIKit

protocol BluetoothVCDelegate: MainViewController {
    func bluetoothConnected(serial: BluetoothSerial)
    func btWriteFailed()
}

class BluetoothVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var connectButtonHeightsConstraint: NSLayoutConstraint!
    @IBOutlet weak var disconnectButtonHeightsConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var peripheralsTableView: UITableView!
    
    var isConnected = false
    var selectedIndex: Int?
    var serial = BluetoothSerial()
    weak var delegate: BluetoothVCDelegate?
    
    @IBAction func connectButton(_ sender: UIButton) {
        if let index = selectedIndex, !isConnected {
            serial.connectToPeripheral(to: index)
            titleLabel.text = "Connecting to peripheral..."
        }
    }
    @IBAction func disconnectButton(_ sender: UIButton) {
        serial.disconnectToPeripheral()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralsTableView.dataSource = self
        peripheralsTableView.delegate = self
        peripheralsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "peripheralCell")
        connectButton.isHidden = true
        disconnectButton.isHidden = true
        connectButtonHeightsConstraint.constant = 0
        disconnectButtonHeightsConstraint.constant = 0
        serial.delegate = self
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        let peripheralInfo = serial.discoveredPeripherals[indexPath.row]
        cell.textLabel?.text = "\(peripheralInfo.peripheral.name ?? "Unknown") - RSSI: \(peripheralInfo.rssi)"
        cell.detailTextLabel?.text = "연결안됨"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serial.discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 체크 마크 추가
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        showConnectButton()
        selectedIndex = indexPath.row
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 다른 셀 선택 시 체크 마크 제거
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    
    func showConnectButton(){
        if connectButton.isHidden && disconnectButton.isHidden {
            connectButtonHeightsConstraint.constant = 36
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            self.connectButton.isHidden = false
        } else {
            connectButtonHeightsConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded()})
            self.connectButton.isHidden = true
        }
    }
    
    func showDisconnectButton(){
        if disconnectButton.isHidden {
            disconnectButtonHeightsConstraint.constant = 36
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            self.disconnectButton.isHidden = false
        }
        else {
            disconnectButtonHeightsConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { self.view.layoutIfNeeded() })
            self.disconnectButton.isHidden = true
        }
    }
}


extension BluetoothVC: BluetoothSerialDelegate {

    func didDiscoverNewPeripheral() {
        DispatchQueue.main.async {
            self.peripheralsTableView.reloadData()
        }
    }
    
    func bluetoothConnected() {
        delegate?.bluetoothConnected(serial: serial)
        titleLabel.text = "Connected"
        showConnectButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 여기에 지연 후 실행할 코드를 넣습니다.
            print("BluetoothPeripheral Connected.")
        }
        showDisconnectButton()
        dismiss(animated: true, completion: nil)
    }
    
    func btWriteFailed() {
        delegate?.btWriteFailed()
    }
    
    func btDisconnectionHandler(error: (any Error)?) {
        isConnected = false
        titleLabel.text = "No Connection"
        let indexPath = IndexPath(row: selectedIndex!, section: 0)
        peripheralsTableView.cellForRow(at: indexPath)?.accessoryType = .none
        //./.peripheralsTableView.reloadData()
        selectedIndex = nil
        showDisconnectButton()
        
        if let error = error {
            let alert = UIAlertController(title: "OK", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 여기에 지연 후 실행할 코드를 넣습니다.
                print("Bluetooth Disconnected.")
            }
            dismiss(animated: true, completion: nil)
            titleLabel.text = "Connect To BluetoothPeripherals"
        }
    }
}

