//
//  ViewController.swift
//  COVID19Bubble
//
//  Created by Yue Li on 2021-02-28.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
    
    let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Header
        self.navigationItem.title = "COVID19-Bubble"
        //Add website
        view.addSubview(webView)
        
        guard let laviaURL = URL(string: "https://www.laviasolutions.ca") else {
            return
        }
        webView.load(URLRequest(url: laviaURL))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }


}

