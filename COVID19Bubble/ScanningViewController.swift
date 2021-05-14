//
//  ScanningViewController.swift
//  COVID19Bubble
//
//  Created by Yue Li on 2021-03-01.
//

import UIKit
//import Foundation
import AVFoundation
import AudioToolbox
import CoreBluetooth


enum Constants: String {
    case SERVICE_UUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
}

//class ScanningViewController: UIViewController {
class ScanningViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource{

    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var name: String?
    
    var peripheral_id = [UUID]()
    let customAlert = MyAlert()
    let scanningDelay = 0.0
    var items = [String: [String: Any]]()
    var switchMap:[Int:String]=[:]
    var defaultUserDefaultKeyLen = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "COVID19-Bubble"
        tableView.delegate = self
        tableView.dataSource = self
        transmittingSwitch.isOn = false
        sensitiveSlider.value = 2
        showDiveceID()
        let defaults = UserDefaults.standard
        if (!defaults.bool(forKey: "chooseToAcknowledge")) {
            customAlert.showAlert(with: "App Notice",
                                  titleImage1:UIImage(named: "launchericon")!,
                                  message1: "* This Application alarms if other users are within the Social Distance bubble.",
                                  message2: "* Family members can be set as In Bubble by turning off the switch",
                                  image1: UIImage(named: "sample")!,
                                  message3:"* Adjust bubble Alarm distance against a device using Sensitivity slider bar",
                                  message4:"*** Please Keep Your Phone Unlock To Detect Other Devices!",
                                  image2: UIImage(named: "slider")!,
                                  on: self)
        }
        
        //for future
//        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification(_:)), name: Notification.Name("text"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didResetNotification(_:)), name: Notification.Name("rssiValue"), object: nil)
        cleanUserDefaults()
        defaultUserDefaultKeyLen = Array(UserDefaults.standard.dictionaryRepresentation().keys).count
    }
    
    @IBOutlet weak var bubbleID: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var transmittingSwitch: UISwitch!
    @IBOutlet weak var switchStatus: UILabel!
    
    func showDiveceID(){
        bubbleID.text = UIDevice.current.name
    }
    
    
    @objc func dismissAlert(){
        customAlert.dismissAlert()
    }
    
    //Get bubble ID from Setting page
//    @objc func didGetNotification(_ notification: Notification){
//        let text = notification.object as! String?
//        bubbleID.text = text
//    }

    //Reset sensitive slider from Setting page
    @objc func didResetNotification(_ notification: Notification){
        sensitiveSlider.value = 2
    }
    
    //start/stop the transmitting
    
    @IBAction func switchDidChange(_sender: UISwitch){
//        let dName = (bubbleID.text)!
        if _sender.isOn{
            startScanning()
            startAdvertising()
            switchStatus.text = "Bubble Scanning ON"
            
        }else{
            stopScanning()
            stopAdv()
            if player != nil{
                player.stop()
            }
            switchStatus.text = "Bubble Scanning Off"
            items.removeAll()
            tableView.reloadData()
        }
    }

    func cleanUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if (key != "chooseToAcknowledge") {
                defaults.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
        print("UserDefault cleaned, and it still have default keys size: " + String(Array(UserDefaults.standard.dictionaryRepresentation().keys).count))
    }
    
    func startScanning(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startAdvertising() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
//    func startAdvertising(name: String) {
//        self.name = name
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
//    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        didReadPeripheral(peripheral, rssi: RSSI, uuid: peripheral.identifier)
//        delay(scanningDelay){
//            peripheral.readRSSI()
//        }
        if !(peripheral_id.contains(peripheral.identifier)){
            peripheral_id.append(peripheral.identifier)
        }
    }
    
    func stopScanning(){
        centralManager.stopScan()
    }
    
    func stopAdv(){
        peripheralManager.stopAdvertising()
    }
    

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn{
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
//        }
        if central.state == .poweredOn {

            let uuid = CBUUID(string: Constants.SERVICE_UUID.rawValue)
            central.scanForPeripherals(withServices: [uuid])

        }
    }
   
    @IBOutlet weak var sensitiveSlider: UISlider!
    
    @IBAction func sliderDidSlide(_sender:UISlider){
        let sliderValue = sensitiveSlider.value
        print(sliderValue)
        switchMap = [Int:String]()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "1" )
        cell.detailTextLabel!.numberOfLines = 2
        
        let defaults = UserDefaults.standard
        let item = itemForIndexPath(indexPath)
        let uuid = item?["uuid"] as! UUID
        let uuidString = uuid.uuidString
        
        let mySwitch = UISwitch()
        //        mySwitch.isOn = false
        
//        if mySwitch.isOn == true{
//            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            AudioServicesPlaySystemSound(SystemSoundID(1005))
//        }
        mySwitch.tag = indexPath.row
        mySwitch.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)
        switchMap.updateValue(uuidString, forKey: indexPath.row)
        //add
//        if (switchMap[indexPath.row] == nil) {
//            switchMap.updateValue(true, forKey: indexPath.row)
//            mySwitch.isOn = true
//        } else {
//            if (switchMap[indexPath.row] == false) {
//                mySwitch.isOn = false
//            } else {
//                mySwitch.isOn = true
//            }
//        }

        if (defaults.string(forKey: uuidString) != nil) {
            if (defaults.bool(forKey: uuidString)) {
                mySwitch.isOn = true
            } else {
                mySwitch.isOn = false
            }
        }
        cell.accessoryView = mySwitch
        
        if (item != nil) {
            cell.textLabel?.text = item!["name"] as? String
            if let rssi = item!["rssi"] as? Int{
                let distance = Double(floor(item!["rssiToDistance"] as! Double*100)/100)
                cell.detailTextLabel!.text = "\(distance) m "
                //>5.01m
                if rssi < -83{
                    cell.textLabel?.textColor = UIColor.lightGray
                    //cell.backgroundColor = UIColor.lightGray
                }
                //>3.98m
                else if rssi < -81{
                    cell.backgroundColor = UIColor.blue
                }
                //>3.16m
                else if rssi < -79{
                    cell.backgroundColor = UIColor.green
                }
                //>2m
                else if rssi < -75{
                    cell.backgroundColor = UIColor.yellow
                }
                //>1m
                else if rssi < -69{
                    cell.backgroundColor = UIColor.orange
                }
                //<=1m rssi>=-69
                else{
                    cell.backgroundColor = UIColor.red
                }
            }
        }
        return cell
    }
    
    //In bubble/outside
    @objc func didChangeSwitch(mySwitch:UISwitch,uuid:String){
        print(switchMap[mySwitch.tag]! as String)
        let defaults = UserDefaults.standard
        let rowId = switchMap[mySwitch.tag]! as String
        
        if  mySwitch.isOn{
//            switchMap.updateValue(true, forKey: mySwitch.tag)
            defaults.set(true, forKey: rowId)
            print("Alarm is ON")
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            AudioServicesPlaySystemSound(SystemSoundID(1005))
            playSound(key: "alarm")
            player.numberOfLoops = -1
        }
        else{
//            switchMap.updateValue(false, forKey: mySwitch.tag)
            defaults.set(false, forKey: rowId)
            print("Alarm is OFF")
            // stop play sound if no device turned on notification
            var stopFlag = true
            for (k, v) in items {
                let uid = v["uuid"] as! UUID
                if (defaults.bool(forKey: uid.uuidString)) {
                    stopFlag = false
                    break
                }
            }
            if (stopFlag) {
                player.stop()
            }
        }
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> [String: Any]?{
        
        if indexPath.row > items.keys.count{
            return nil
        }
        return Array(items.values)[indexPath.row]
    }
    
    func didReadPeripheral(_ peripheral: CBPeripheral, rssi: NSNumber, uuid: UUID ){
        let rssiToDistance =  pow(10, ((-69-Double(truncating: rssi))/(10*2)))
        let defaults = UserDefaults.standard

        if peripheral.name != nil {
            let name = peripheral.name
            if Float(truncating: NSNumber(value: rssiToDistance)) < sensitiveSlider.value{
                
                items[name!] = [
                        "name":name as Any,
                        "rssi":rssi,
                        "uuid":uuid,
                        "rssiToDistance":rssiToDistance
                    ]
                if (defaults.string(forKey: uuid.uuidString) == nil) {
                    print("New device found with uuid: " + uuid.uuidString + ", current device list has size: " + String(Array(defaults.dictionaryRepresentation().keys).count - defaultUserDefaultKeyLen))
                    print(peripheral.name!)
                    defaults.set(true, forKey: uuid.uuidString)
                }
                //add by Michelle 2nd fix
                if (defaults.bool(forKey: uuid.uuidString)) {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                    AudioServicesPlaySystemSound(SystemSoundID(1005))
                    playSound(key: "alarm")
                    player.numberOfLoops = -1
                }
                // stop play sound if no device turned on notification
                var stopFlag = true
                for (k, v) in items {
                    let uid = v["uuid"] as! UUID
                    if (defaults.bool(forKey: uid.uuidString)) {
                        stopFlag = false
                        break
                    }
                }
                if (stopFlag) {
                    player.stop()
                }
            }
            tableView.reloadData()
            // Check if reload required
//            var reload = true
//            if items.count == 1{
//                reload = true
//            }
//            else {
//                for (k, v) in items {
//                    let uid = v["uuid"] as! UUID
//                    if (uid == uuid) {
//                        reload = false
//                        break
//                    }
//                }
//            }
//            if (reload) {
//                tableView.reloadData()
//                print("GUI reloaded!")
//            }
        }
    }
}

extension ScanningViewController: CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
            }
            let uuid = CBUUID(string: Constants.SERVICE_UUID.rawValue)
            var advertisingData: [String : Any] = [
                CBAdvertisementDataServiceUUIDsKey: [uuid]
            ]
//            if let name = self.name {
//                advertisingData[CBAdvertisementDataLocalNameKey] = name
//            }
            if let name = bubbleID.text{
                advertisingData[CBAdvertisementDataLocalNameKey] = name
            }
            self.peripheralManager?.startAdvertising(advertisingData)
        }
        
//        else {
//            #warning("handle other states")
//        }
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

class MyAlert {
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    let checkbox = CircularCheckbox(frame: CGRect(x: 0, y: 330, width: 20, height: 20))
    
    private let backgroudView: UIView = {
        let backgrandView = UIView()
        backgrandView.backgroundColor = .black
        backgrandView.alpha = 0
        return backgrandView
    }()
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()
    
    private var mytargetView:UIView?
    
    func showAlert(with title: String,
                   titleImage1:UIImage,
                   message1: String,
                   message2: String,
                   image1: UIImage,
                   message3: String,
                   message4: String,
                   image2: UIImage,
                   on ViewController: UIViewController){
        guard let targetView = ViewController.view else{
            return
        }
        
        mytargetView = targetView
        
        backgroudView.frame = targetView.bounds
        targetView.addSubview(backgroudView)
        
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: targetView.frame.size.width-68,
                                 height: 400)
        
        let titleImage = UIImageView(frame:CGRect(x: 20,
                                                  y: 20,
                                                  width: 40,
                                                  height: 40))
        titleImage.image = titleImage1
        alertView.addSubview(titleImage)
        
        
        let titleLabel = UILabel(frame: CGRect(x: 80,
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 80))
        titleLabel.text = title
        titleLabel.textColor = .black
//        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        
        let messageLabel1 = UILabel(frame: CGRect(x: 5,
                                               y: 10,
                                               width: alertView.frame.size.width-10,
                                               height: 160))
        messageLabel1.numberOfLines = 0
        messageLabel1.text = message1
        messageLabel1.textColor = .gray
        messageLabel1.textAlignment = .left
        alertView.addSubview(messageLabel1)
        
        let messageLabel2 = UILabel(frame: CGRect(x: 5,
                                               y: 50,
                                               width: alertView.frame.size.width-10,
                                               height: 160))
        messageLabel2.numberOfLines = 0
        messageLabel2.text = message2
        messageLabel2.textColor = .gray
        messageLabel2.textAlignment = .left
        alertView.addSubview(messageLabel2)
        
        let imageLabel1 = UIImageView(frame: CGRect(x: 20,
                                                    y: 150,
                                                    width: alertView.frame.size.width-40,
                                                    height:30))
        imageLabel1.image = image1
        alertView.addSubview(imageLabel1)
        
        let messageLabel3 = UILabel(frame: CGRect(x: 5,
                                               y: 120,
                                               width: alertView.frame.size.width-10,
                                               height: 160))
        messageLabel3.numberOfLines = 0
        messageLabel3.text = message3
        messageLabel3.textColor = .gray
        messageLabel3.textAlignment = .left
        alertView.addSubview(messageLabel3)
        
        let imageLabel2 = UIImageView(frame: CGRect(x: 20,
                                                    y: 220,
                                                    width: alertView.frame.size.width-40,
                                                    height:30))
        imageLabel2.image = image2
        alertView.addSubview(imageLabel2)
        
        let messageLabel4 = UILabel(frame: CGRect(x: 5,
                                               y: 200,
                                               width: alertView.frame.size.width-10,
                                               height: 160))
        messageLabel4.numberOfLines = 0
        messageLabel4.text = message4
        messageLabel4.textColor = .red
        messageLabel4.font = UIFont.boldSystemFont(ofSize: 18.0)
        messageLabel4.textAlignment = .left
        alertView.addSubview(messageLabel4)
        
        let label = UILabel(frame: CGRect(x: 20, y: 330, width: alertView.frame.size.width, height: 20))

        label.numberOfLines = 0
        label.text = "Please do not show this message again"
        label.font = label.font.withSize(16)
        label.textColor = .gray
        label.textAlignment = .left
        alertView.addSubview(label)

        alertView.addSubview(checkbox)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkbox.addGestureRecognizer(gesture)
        
        let button = UIButton(frame: CGRect(x: 0,
                                            y: alertView.frame.size.height-50,
                                            width: alertView.frame.size.width,
                                            height: 50))
        
        button.setTitle("Ok", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert),
                         for: .touchUpInside)
        alertView.addSubview(button)
        
        UIView.animate(withDuration: 0.25,
                       animations: {
                        
                        self.backgroudView.alpha = Constants.backgroundAlphaTo
                        
                       }, completion: {done in
                        if done {
                            UIView.animate(withDuration: 0.25, animations: {
                                self.alertView.center = targetView.center
                                           })
                        }
                       })
    }
    
    @ objc func didTapCheckbox(){
        checkbox.toggle()
    }
    
    @objc func dismissAlert(){
        guard let targetView = mytargetView else {
            return
        }
        UIView.animate(withDuration: 0.25,
                       animations: {
                        
                        self.alertView.frame = CGRect(x: 40,
                                                      y: targetView.frame.size.height,
                                                      width: targetView.frame.size.width-80,
                                                      height: 300)
                       }, completion: {done in
                        if done {
                            UIView.animate(withDuration: 0.25, animations: {
                                self.backgroudView.alpha = 0
                            },completion: { done in
                                if done {
                                    self.alertView.removeFromSuperview()
                                    self.backgroudView.removeFromSuperview()
                                }
                            })
                        }
                       })
    }
    
}
