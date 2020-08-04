// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Debug android studio: search Restart flutter daemon (shift + shift to search)

import UIKit
import Flutter
import CoreBluetooth
import Foundation


enum ChannelName {
    static let sensor = "samples.flutter.io/sensor"
}

enum MyFlutterErrorCode {
    static let unavailable = "UNAVAILABLE"
}

// MARK: - Core Bluetooth service IDs
let service_UUID = CBUUID(string: "0000dfb0-0000-1000-8000-00805f9b34fb")

// MARK: - Core Bluetooth characteristic IDs
let characteristic_UUID = CBUUID(string: "0000dfb1-0000-1000-8000-00805f9b34fb")

var NAME_DEVICE = ""

var macAddress = ""

var isConnected = false

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    var btConnexion = ViewController()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        let sensorChannel = FlutterMethodChannel(name: ChannelName.sensor,
                                                 binaryMessenger: controller.binaryMessenger)
        
        sensorChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            let methodArray = (call.method).components(separatedBy: ",")
            
            if(methodArray.capacity > 1){
                NAME_DEVICE = methodArray[1]

                if(methodArray.capacity > 2){
                    macAddress = methodArray[2]
                    
                }
            }
            
            
            guard methodArray[0] == "connect" else {
                guard call.method == "getBLEState" else {
                    guard call.method == "getData" else {
                        guard methodArray[0] == "getPairedDevices" else {
                            guard call.method == "getStatus" else {
                            guard call.method == "disconnect" else {
                                result(FlutterMethodNotImplemented)
                                return
                                }
                                self?.btConnexion.disconnect()
                                return
                            }
                            result(self?.btConnexion.getStatus())
                            return
                        }
                        result(self?.btConnexion.getUUID())
                        return
                        }
                    result(self?.btConnexion.getValue())
                    return
                    }
                result(self?.btConnexion.getBLEState())
                return
                }
            self?.btConnexion.connect(macAddress: macAddress)
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        guard device.batteryState != .unknown  else {
            result(FlutterError(code: MyFlutterErrorCode.unavailable,
                                message: "Battery info unavailable",
                                details: nil))
            return
        }
        result(Int(device.batteryLevel * 100))
    }

    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var value: String = "0"
    var uuid: String = "0"
    var isOn: Bool = false

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if #available(iOS 10.0, *) {
            if central.state == CBManagerState.poweredOn {
                print("BLE powered on")
                isOn = true
                // Turned on
                central.scanForPeripherals(withServices: nil, options: nil)
            }
            else {

                print("Something wrong with BLE")
                isOn = false
                // Not on, but can have different issues
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(peripheral)")

        //Stop Scan- We don't need to scan once we've connected to a peripheral. We got what we came for.
        centralManager?.stopScan()
        print("Scan Stopped")

        //Erase data that we might have
        //data.length = 0

        //Discovery callback
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([service_UUID])
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let pname = peripheral.name {
            if pname == NAME_DEVICE {
                self.centralManager.stopScan()

                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                uuid = self.myPeripheral.identifier.uuidString
                
                setUUID(tempUUID: uuid)
                
                print(peripheral.identifier.uuidString)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {

            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("*******************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            return
        }

        print("Found \(characteristics.count) characteristics!")

        for characteristic in characteristics {
            //looks for the right characteristic

            if characteristic.uuid.isEqual(characteristic_UUID)  {
                //let rxCharacteristic = characteristic

                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: characteristic)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)

                print("Rx Characteristic: \(characteristic.uuid)")

            }
            //peripheral.discoverDescriptors(for: characteristic)
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        let value = characteristic.value!

        let temp = String(bytes: value, encoding: .utf8)

        //print(temp as Any)

        setValue(_value: temp!)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func getUUID() -> String{
        
        self.viewDidLoad()
    
        return uuid
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func setUUID(tempUUID : String){
        
        uuid = tempUUID
            
        print(uuid)
    
    }
    
    func connect(macAddress:String){
        
        if self.myPeripheral == nil {
            viewDidLoad()
        }else{
            self.centralManager.connect(self.myPeripheral, options: nil)
            isConnected = true
        }
    }
    
    func getBLEState() -> Bool{

        if #available(iOS 10.0, *) {
            if(CBManagerState.poweredOn.rawValue == 5){
                isOn = true
            }
            else if(CBManagerState.poweredOff.rawValue == 4){
                isOn = false
            }
        } else {
            // Fallback on earlier versions
        }
        return isOn
    }
    
    func disconnect(){
        self.centralManager.cancelPeripheralConnection(self.myPeripheral)
        isConnected = false
    }

    func setValue(_value: String ){
        value = _value
    }

    func getValue() -> String{
        return value
    }
    
    func getStatus() -> Bool{
        //self.viewDidLoad()
        return isConnected
    }

}
 
