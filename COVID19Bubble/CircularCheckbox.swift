//
//  CircularCheckbox.swift
//  COVID19Bubble
//
//  Created by Yue Li on 2021-03-25.
//

import UIKit

final class CircularCheckbox: UIView {
    
    var isChecked = false
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.cornerRadius = frame.size.width / 2.0
        backgroundColor = .systemBackground
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func toggle(){
        self.isChecked = !isChecked
        let defaults = UserDefaults.standard
        if self.isChecked{
            backgroundColor = .systemBlue
            defaults.set(true, forKey: "chooseToAcknowledge")
        }
        else{
            backgroundColor = .systemBackground
            defaults.set(false, forKey: "chooseToAcknowledge")
        }
    }

}

