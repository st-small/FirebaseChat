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
    
    func addPoleForButtonsToKeyboard(myAction: Selector?, buttonNeeds: Bool) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.backgroundColor = .white
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
        
        if buttonNeeds {
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Return", style: UIBarButtonItemStyle.done, target: self, action: myAction)
            done.tintColor = UIColor.blue
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
        }
    }
}
