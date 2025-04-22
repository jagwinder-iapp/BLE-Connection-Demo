//
//  BluetoothManager.swift
//  BLE Connection
//
//  Created by iapp on 22/04/25.
//

import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var espPeripheral: CBPeripheral?
    private var writableCharacteristic: CBCharacteristic?
    
    @Published var isConnected = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning for devices...")
        } else {
            print("Bluetooth is not available")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth is not available")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("peripheral.name", peripheral.name ?? "mo name")
        if let name = peripheral.name, name == "ESP32_Relay" {
            print("Found ESP32: \(name)")
            espPeripheral = peripheral
            espPeripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "ESP32")")
        isConnected = true
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from ESP32")
        isConnected = false
        startScanning()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    print("Found writable characteristic")
                    writableCharacteristic = characteristic
                }
            }
        }
    }
    
    func sendCommand(_ command: String) {
        guard let espPeripheral = espPeripheral, let writableCharacteristic = writableCharacteristic else {
            print("ESP32 not connected or writable characteristic not found")
            return
        }
        
        let data = command.data(using: .utf8)!
        espPeripheral.writeValue(data, for: writableCharacteristic, type: .withResponse)
        print("Sent command: \(command)")
    }
}
