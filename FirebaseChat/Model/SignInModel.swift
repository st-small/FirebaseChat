//
//  SignInModel.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 14.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol SignInModelProtocol {
    func stackViewSpacing(_ screenHeight: Double) -> Double
    func sendCode(_ phoneNumber: String, callback: @escaping ()->())
    func showVerificationView(callback: @escaping ()->())
    func checkCode(_ code: String, callback: @escaping ()->())
}

class SignInModel: SignInModelProtocol {
    func stackViewSpacing(_ screenHeight: Double) -> Double {
        return screenHeight < 600 ? 10.0 : 20.0
    }
    
    func sendCode(_ phoneNumber: String, callback: @escaping ()->()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let defaults = UserDefaults.standard
                defaults.set(verificationID, forKey: "authVID")
                callback()
            }
        }
    }
    
    func checkCode(_ code: String, callback: @escaping ()->()) {
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: code)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Phone number: \(String(describing: user?.phoneNumber))")
                let userInfo = user?.providerData[0]
                print("Provider ID: \(String(describing: userInfo?.providerID))")
                callback()
            }
        }
    }
    
    func showVerificationView(callback: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: callback)
    }
}
