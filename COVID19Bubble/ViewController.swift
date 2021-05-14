//
//  ViewController.swift
//  COVID19Bubble
//
//  Created by Yue Li on 2021-03-22.
//

import UIKit
import Foundation

class Viewcontroller: UIViewController{
    
    @IBOutlet var myButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myButton.backgroundColor = .link
        myButton.setTitleColor(.white, for: .normal)
        myButton.setTitle("Show Alert", for: .normal)
    }
    
    @IBAction func didTapButton(){
        //do stuff
    }
}
