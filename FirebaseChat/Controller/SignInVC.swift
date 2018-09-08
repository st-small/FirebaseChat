//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 13.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class SignInVC: UIViewController, UITextFieldDelegate, Alertable {
    
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
    @IBOutlet weak var getCode: UIButton!
    @IBOutlet weak var logIn: UIButton!
    
    // MARK: - Properties -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add custom button to hide keyboard when numberPad is showing
        phoneNum?.addPoleForButtonsToKeyboard(myAction: #selector(phoneNum.resignFirstResponder), buttonNeeds: true)
        
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
    
    // MARK: - TextFieldDelegate -
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // moving by text fields using return button
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
        // use text field's validation by phoneNumber and verification code
        if textField == phoneNum {
            let result = String().checkPhoneNumber(textField.text!, in: range, replacement: string)
            textField.text = result.1
            if result.1.characters.count == 19 {
                getCode.sendActions(for: .touchUpInside)
            }
            return result.0
        } else if textField == codeTF {
            let result = String().checkCode(textField.text!, in: range, replacement: string)
            textField.text = result.1
            if result.1.characters.count == 6 {
                logIn.sendActions(for: .touchUpInside)
            }
            return result.0
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // if user select text field with phone number, show +38 for him
        if textField == phoneNum && textField.text == "" {
            phoneNum.hideRedUnderline()
            textField.text = "+38 "
        }
    }
    
    // MARK: - Actions -
    @IBAction func sendCode(_ sender: UIButton) {
        // send button logic
        // check empty phone number's text field
        guard !(phoneNum.text?.isEmpty)! && phoneNum.text != "+38 " else {
            showAlert(title: "Ошибка ввода!", message: "Ввведите номер телефона", actionTitle: "ОК")
            UIView.animate(withDuration: 0.3, animations: {
                self.phoneNum.useRedUnderline()
            })
            return
        }
        // set anonymous name if user name didn't fill
        if nicknameTF.text != nil {
            let defaults = UserDefaults.standard
            defaults.set(nicknameTF.text, forKey: "userName")
            defaults.synchronize()
        }
        
        // send verification code to check user's input
        model.sendCode(phoneNum.text!, callback: {
            self.showActivitySpinner()
            self.model.showVerificationView(callback: {
                self.hideActivitySpinner()
                self.showVerificationEnterTF()
            })
        })
        
    }
    
    // action to log into app after verification code and if it was accepted
    @IBAction func logIN(_ sender: UIButton) {
        if let code = codeTF.text, code != "" {
            model.checkCode(code, callback: {
                self.openLoggedVC()
            })
        }
    }
    
    // MARK: - Private methods -
    // hide keyboard method
    private func resign() {
        phoneNum.resignFirstResponder()
        nicknameTF.resignFirstResponder()
    }
    
    // show waiting activity indicator
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
    
    // hide indicator after 5 sec while
    private func hideActivitySpinner() {
        UIView.animate(withDuration: 0.3) {
            self.grayView.alpha = 0
            self.indicator.stopAnimating()
            self.loadViewIfNeeded()
        }
    }
    
    // hide nickname and phone number text fields and show verification input text field
    private func showVerificationEnterTF() {
        UIView.animate(withDuration: 0.3) {
            self.stackView2.isHidden = false
        }
    }
    
    // enter messages view controller
    private func openLoggedVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
}
