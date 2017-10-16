//
//  Alertable.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 15.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit

protocol Alertable {}

extension Alertable where Self: UIViewController {
    
    // alert generic method
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle:. alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alertView.addAction(okAction)
        present(alertView, animated: true, completion: nil)
    }
}

