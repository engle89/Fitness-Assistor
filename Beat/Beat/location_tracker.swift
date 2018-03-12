//
//  location_tracker.swift
//  Beat
//
//  Created by PengYi on 3/7/17.
//  Copyright © 2017 霍晟悦. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import CoreBluetooth

var globaldist = 0.0
var Customer_distance = 0.0

class location_tracker:UIViewController,
    CLLocationManagerDelegate, MKMapViewDelegate,
    CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    var viewcontroller:ViewController? = nil
    
    
    @IBOutlet weak var TheMap: MKMapView!
    @IBOutlet weak var TheLabel: UILabel!
    @IBOutlet weak var TheLabel2: UILabel!
    
    @IBOutlet weak var TheLabel3: UILabel!
    
    //location tracker
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    //heart rate
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    let POLARH7_HRM_HEART_RATE_SERVICE_UUID = "180D"
    let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = "180A"


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewcontroller = ViewController()
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup our Map View
        TheMap.delegate = self
        TheMap.mapType = MKMapType.standard
        TheMap.showsUserLocation = true
        
        //heart rate part
        let heartRateServiceUUID = CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID)
        let deviceInfoServiceUUID = CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)
        
        let services = [heartRateServiceUUID, deviceInfoServiceUUID];
        
        //let centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        let centralManager = CBCentralManager(delegate: self, queue: nil)
        
        centralManager.scanForPeripherals(withServices: services, options: nil)
        
        //[centralManager scanForPeripheralsWithServices:services options:nil];
        self.centralManager = centralManager;
        

    }
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        //theLabel.text = "\(locations[0])"
        myLocations.append(locations[0] as! CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        let newRegion = MKCoordinateRegion(center: TheMap.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        TheMap.setRegion(newRegion, animated: true)
        
        if (myLocations.count > 1){
            let sourceIndex = myLocations.count - 1
            let destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            TheMap.add(polyline)
            
            // let deltax=c2.latitude-c1.latitude
            // let deltay=c2.longitude-c1.longitude
            // var dist=sqrt(deltax*deltax+deltay*deltay)
            
            globaldist = myLocations[destinationIndex].speed + globaldist
            
            TheLabel.text = "speed: \(myLocations[destinationIndex].speed) m/s"
            TheLabel2.text = "distance: \(globaldist) m"
            
            
            
        }
    }
    
    
    @IBOutlet weak var showAlert: UIButton!
    @IBAction func showAlert(_ sender: UIButton) {
        Customer_distance = viewcontroller!.customer_distance()
        
        if(globaldist > Customer_distance)
        {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Alert", message: "you are finished", preferredStyle: .alert)
            
            
            
            // Initialize Actions
            let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            }
            
            
            // Add Actions
            alertController.addAction(yesAction)
            
            
            // Present Alert Controller
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Alert", message: "you are not finished", preferredStyle: .alert)
            
            
            
            // Initialize Actions
            let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            }
            
        
            
            // Add Actions
            alertController.addAction(yesAction)
          
            
            
            // Present Alert Controller
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }
    
    /*override func didReceiveMemoryWarning() {
     super.didReceiveMemoryWarning()
     // Dispose of any resources that can be recreated.
     }*/
    
    //heart rate part
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("--- centralManagerDidUpdateState")
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            
            let serviceUUIDs:[AnyObject] = [CBUUID(string: "180D")]
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs as! [CBUUID])
            
            if lastPeripherals.count > 0{
                let device = lastPeripherals.last! as CBPeripheral;
                connectingPeripheral = device;
                centralManager.connect(connectingPeripheral, options: nil)
            }
            else {
                centralManager.scanForPeripherals(withServices: serviceUUIDs as? [CBUUID], options: nil)
                
            }
        case .poweredOff:
            print("--- central state is powered off")
        case .resetting:
            print("--- central state is resetting")
        case .unauthorized:
            print("--- central state is unauthorized")
        case .unknown:
            print("--- central state is unknown")
        case .unsupported:
            print("--- central state is unsupported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("--- didDiscover peripheral")
        
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String{
            print("--- found heart rate monitor named \(localName)")
            self.centralManager.stopScan()
            connectingPeripheral = peripheral
            connectingPeripheral.delegate = self
            centralManager.connect(connectingPeripheral, options: nil)
        }else{
            print("!!!--- can't unwrap advertisementData[CBAdvertisementDataLocalNameKey]")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("--- didConnectPeripheral")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("--- peripheral state is \(peripheral.state)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error) != nil{
            print("!!!--- error in didDiscoverServices: \(error?.localizedDescription)")
        }
        else {
            print("--- error in didDiscoverServices")
            for service in peripheral.services as [CBService]!{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error) != nil{
            print("!!!--- error in didDiscoverCharacteristicsFor: \(error?.localizedDescription)")
        }
        else {
            
            if service.uuid == CBUUID(string: "180D"){
                for characteristic in service.characteristics! as [CBCharacteristic]{
                    switch characteristic.uuid.uuidString{
                        
                    case "2A37":
                        // Set notification on heart rate measurement
                        print("Found a Heart Rate Measurement Characteristic")
                        peripheral.setNotifyValue(true, for: characteristic)
                        
                    case "2A38":
                        // Read body sensor location
                        print("Found a Body Sensor Location Characteristic")
                        peripheral.readValue(for: characteristic)
                        
                    case "2A29":
                        // Read body sensor location
                        print("Found a HRM manufacturer name Characteristic")
                        peripheral.readValue(for: characteristic)
                        
                    case "2A39":
                        // Write heart rate control point
                        print("Found a Heart Rate Control Point Characteristic")
                        
                        var rawArray:[UInt8] = [0x01];
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                        
                    default:
                        print()
                    }
                    
                }
            }
        }
    }
    
    func update(heartRateData:Data){
        print("--- UPDATING ..")
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            print(actualBpm)
            TheLabel3.text = ("\(actualBpm)")
        }else {
            TheLabel3.text = ("\(bpm!)")
            print(bpm!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("--- didUpdateValueForCharacteristic")
        
        if (error) != nil{
            
        }else {
            switch characteristic.uuid.uuidString{
            case "2A37":
                update(heartRateData:characteristic.value!)
                
            default:
                print("--- something other than 2A37 uuid characteristic")
            }
        }
    }

    


}
