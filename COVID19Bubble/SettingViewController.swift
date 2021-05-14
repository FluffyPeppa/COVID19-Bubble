//
//  SettingViewController.swift
//  COVID19Bubble
//
//  Created by Yue Li on 2021-03-01.
//

import UIKit

class SettingViewController: UIViewController {
    
    //public var completionHandler:((String?)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "COVID19-Bubble"
//        deviceName.returnKeyType = .done
//        deviceName.autocapitalizationType = .words
//        deviceName.autocorrectionType = .no
//        deviceName.delegate = self
        
    }
    
//    @IBOutlet weak var deviceName: UITextField!
    
    @IBAction func resetBubbleSize(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("rssiValue"), object: nil)
        print("Reset Bubble Size")
    }
    
    
//    @IBAction func didTapSave(_ sender: Any) {
//        //completionHandler?(deviceName.text)
//        deviceName.resignFirstResponder()
//        NotificationCenter.default.post(name: NSNotification.Name("text"), object: deviceName.text)
//        dismiss(animated: true, completion: nil)
//    }
    
}

//extension SettingViewController: UITextFieldDelegate{
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}

