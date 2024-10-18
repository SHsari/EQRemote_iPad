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
}

class BluetoothVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var peripheralsTableView: UITableView!
    
    var isConnected = false
    var serial: BluetoothSerial?
    weak var delegate: BluetoothVCDelegate?
    
    var checkedIndexPath: IndexPath?
    
    @IBAction func connectButton(_ sender: UIButton) {
        guard let serial = serial else { return }
        if isConnected {
            serial.disconnectToPeripheral()
        } else if let indexPath = checkedIndexPath {
            sender.titleLabel?.text = "Connecting..."
            serial.connectToPeripheral(to: indexPath.row)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        peripheralsTableView.dataSource = self
        peripheralsTableView.delegate = self
        peripheralsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "peripheralCell")
        connectButton.isHidden = true
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isConnected {
            let serial = BluetoothSerial()
            serial.delegate = self
            self.serial = serial
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        guard let serial = serial else { return cell }
        let peripheralInfo = serial.discoveredPeripherals[indexPath.row]
        cell.textLabel?.text = "\(peripheralInfo.peripheral.name ?? "Unknown") - RSSI: \(peripheralInfo.rssi)"
        cell.detailTextLabel?.text = "연결안됨"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let serial = serial else { return 0 }
        return serial.discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isConnected else { return }
        if checkedIndexPath == indexPath {
            connectButton.isEnabled = false
        } else {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                connectButton.isEnabled = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard !isConnected else { return }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: true)
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
        guard let serial = serial else { return }
        delegate?.bluetoothConnected(serial: serial)
        if let ip = checkedIndexPath, let cell = peripheralsTableView.cellForRow(at: ip) {
            var content = cell.defaultContentConfiguration()
            content.secondaryText = "Connected"
            cell.contentConfiguration = content
        }
        self.isConnected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.connectButton.titleLabel?.text = "Disconnect"
        }
        dismiss(animated: true, completion: nil)
    }
    
    func btWriteFailed() {
        serial?.disconnectToPeripheral()
        delegate?.btWriteFailed()
    }
    
    func btDisconnectionHandler(error: (any Error)?) {
        isConnected = false
        connectButton.titleLabel?.text = "Connect"/*
        if let indexPath = checkedIndexPath {
            if let cell = peripheralsTableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
                var content = cell.defaultContentConfiguration()
                content.secondaryText = ""
                cell.contentConfiguration = content
                checkedIndexPath = nil
            }
        }*/
        serial = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.peripheralsTableView.reloadData()
        }

        var errMessage = ""
        if let error = error { errMessage = error.localizedDescription }
        let alert = UIAlertController(title: "Bluetooth Disconnected", message: errMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        delegate?.bluetoothDisconnected(alert: alert)
        dismiss(animated: true, completion: nil)
    }
}

