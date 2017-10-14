//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 13.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController, UITextFieldDelegate {
    
    let model = SignInModel()
    
    // MARK: - Outlets -
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.spacing = CGFloat(model.stackViewSpacing(Double(UIScreen.main.bounds.size.height)))
        }
    }
    @IBOutlet weak var stackView2: UIStackView! { didSet { stackView2.isHidden = true
        } }
    @IBOutlet weak var nicknameTF: UITextField!
    @IBOutlet weak var phoneNum: UITextField! 
    @IBOutlet weak var indicator: UIActivityIndicatorView! { didSet { indicator.alpha = 0 }}
    @IBOutlet weak var grayView: UIView! { didSet { grayView.alpha = 0 }}
    @IBOutlet weak var codeTF: UITextField!
    
    // MARK: - Properties -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add custom button to hide keyboard when numberPad is showing
        phoneNum?.addPoleForButtonsToKeyboard(myAction: #selector(phoneNum.resignFirstResponder), buttonNeeds: true)
    }
    
    // MARK: - TextFieldDelegate -
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameTF {
            nicknameTF.resignFirstResponder()
            phoneNum.becomeFirstResponder()
        } else if textField == phoneNum {
            phoneNum.resignFirstResponder()
        } else {
            codeTF.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneNum {
            let result = String().checkPhoneNumber(textField.text!, in: range, replacement: string)
            textField.text = result.1
            return result.0
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneNum && textField.text == "" {
            textField.text = "+38 "
        }
    }
    
    // MARK: - Actions -
    @IBAction func sendCode(_ sender: UIButton) {
        if phoneNum.text != nil {
            model.sendCode(phoneNum.text!, callback: { 
                self.showActivitySpinner()
                self.model.showVerificationView(callback: {
                    self.hideActivitySpinner()
                    self.showVerificationEnterTF()
                })
            })
        }
    }
    
    @IBAction func logIN(_ sender: UIButton) {
        if let code = codeTF.text, code != "" {
            model.checkCode(code, callback: {
                self.openLoggedVC()
            })
        }
    }
    
    // MARK: - Private methods -
    private func resign() {
        phoneNum.resignFirstResponder()
        nicknameTF.resignFirstResponder()
    }
    
    private func showActivitySpinner() {
        resign()
        UIView.animate(withDuration: 0.7) {
            self.grayView.alpha = 0.6
            self.grayView.backgroundColor = UIColor.lightGray
            
            self.indicator.alpha = 1
            self.indicator.startAnimating()
            
            self.stackView.isHidden = true
        }
    }
    
    private func hideActivitySpinner() {
        UIView.animate(withDuration: 0.3) {
            self.grayView.alpha = 0
            self.indicator.stopAnimating()
            self.loadViewIfNeeded()
        }
    }
    
    private func showVerificationEnterTF() {
        UIView.animate(withDuration: 0.3) {
            self.stackView2.isHidden = false
        }
    }
    
    private func openLoggedVC() {
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoggedVC") as! LoggedVC
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        self.present(vc, animated: true, completion: nil)
    }
}
