//
//  UITextField+Extension.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 14.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    // add custom pole for numPad iPhone
    func addPoleForButtonsToKeyboard(myAction: Selector?, buttonNeeds: Bool) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor = .white
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
        
        if buttonNeeds {
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Скрыть", style: UIBarButtonItemStyle.done, target: self, action: myAction)
            done.tintColor = UIColor.blue
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
        }
    }
    
    // red frame to show wrong value in textField
    func useRedUnderline() {
        let border = CALayer()
        border.name = "border"
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.red.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    // hiding red frame in textField
    func hideRedUnderline() {
        for layer in self.layer.sublayers! {
            if layer.name == "border" {
                layer.removeFromSuperlayer()
            }
        }
    }
}
