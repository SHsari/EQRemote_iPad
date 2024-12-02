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
    func bluetoothDisconnected(alert: UIAlertController)
    func requestFromHW(command: String);
}

class BluetoothVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var peripheralsTableView: UITableView!
    
    var isConnected = false
    var serial: BluetoothSerial?
    weak var delegate: BluetoothVCDelegate?
    
    var selectedIP: IndexPath?
    
    @IBAction func connectButton(_ sender: UIButton) {
        guard let serial = serial else { return }
        if isConnected {
            serial.disconnectToPeripheral()
        } else if let ipath = selectedIP {
            sender.isUserInteractionEnabled = false
            sender.setTitle("Connecting...", for: .normal)
            serial.connectToPeripheral(to: ipath.row)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralsTableView.dataSource = self
        peripheralsTableView.delegate = self
        let nib = UINib(nibName: "BTPeripheralCell", bundle: nil)
        peripheralsTableView.register(nib, forCellReuseIdentifier: "BTPeripheralCell")
        connectButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isConnected {
            let serial = BluetoothSerial()
            serial.delegate = self
            self.serial = serial
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        connectButton.isUserInteractionEnabled = true
        if isConnected {
            connectButton.setTitle("Disconnect", for: .normal)
        } else {
            serial = nil
            selectedIP = nil
            connectButton.setTitle("Connect", for: .normal)
            connectButton.isEnabled = false
            peripheralsTableView.reloadData()
            self.peripheralsTableView.allowsSelection = true
            self.titleLabel.text = "Available Bluetooth Devices"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Devices"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BTPeripheralCell", for: indexPath) as? BTPeripheralCell else { return UITableViewCell() }
        guard let serial = serial else { return cell }
        let peripheralInfo = serial.discoveredPeripherals[indexPath.row]
        cell.PeripheralName.text = "\(peripheralInfo.peripheral.name ?? "Unknown")"
        cell.setStrength(rssi: peripheralInfo.rssi)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let serial = serial else { return 0 }
        return serial.discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIP == indexPath {
            selectedIP = nil
            self.connectButton.isEnabled = false
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedIP = indexPath
            self.connectButton.isEnabled = true
        }
    }
    
}


extension BluetoothVC: BluetoothSerialDelegate {
    func requestFromHW(command: String) {
        delegate?.requestFromHW(command: command)
    }
    
    func didDiscoverNewPeripheral(_ lastIndex: Int) {
        let ip = IndexPath(row: lastIndex, section: 0)
        peripheralsTableView.insertRows(at: [ip], with: .automatic)
    }
    func updateRssi(rssi: NSNumber, at index: Int) {
        let ip = IndexPath(row: index, section: 0)
        if let cell = peripheralsTableView.cellForRow(at: ip) as? BTPeripheralCell {
            cell.setStrength(rssi: rssi)
        }
    }
    
    func didRemovePeripheral(at index: Int) {
        let ip = IndexPath(row: index, section: 0)
        peripheralsTableView.deleteRows(at: [ip], with: .fade)
        guard let selected = selectedIP else { return }
        if ip == selected { selectedIP = nil; connectButton.isEnabled = false }
        else if ip < selected { selectedIP = IndexPath(row: selected.row - 1, section: 0) }
    }
    
    func bluetoothConnected() {
        guard let serial = serial else { return }
        self.isConnected = true
        peripheralsTableView.allowsSelection = false
        titleLabel.text = "Device Connected"
        delegate?.bluetoothConnected(serial: serial)
        if let ip = selectedIP,
           let cell = peripheralsTableView.cellForRow(at: ip) as? BTPeripheralCell {
            cell.setConnected(true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func btWriteFailed() {
        serial?.disconnectToPeripheral()
        delegate?.btWriteFailed()
    }
    
    func btDisconnectionHandler(error: (any Error)?) {
        isConnected = false
        if let ip = selectedIP {
            let cell = peripheralsTableView.cellForRow(at: ip) as? BTPeripheralCell
            cell?.setConnected(false)
        }
        
        
        serial = nil
        selectedIP = nil
        connectButton.setTitle("Connect", for: .normal)
        connectButton.isEnabled = false
        peripheralsTableView.reloadData()
        self.peripheralsTableView.allowsSelection = true
        self.titleLabel.text = "Available Bluetooth Devices"
        

        var errMessage = ""
        if let error = error { errMessage = error.localizedDescription }
        let alert = UIAlertController(title: "Bluetooth Disconnected", message: errMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        dismiss(animated: true) { [weak self] in
            self?.delegate?.bluetoothDisconnected(alert: alert)
        }
    }
}

