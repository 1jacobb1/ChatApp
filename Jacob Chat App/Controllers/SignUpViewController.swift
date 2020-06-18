//
//  SignUpViewController.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/17/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var lblUsernameError: UILabel!
    @IBOutlet weak var lblUsernameErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblPasswordErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var lblLogin: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ensure form error hidden
        formError(show: false)
        
        // ensure buttons are enabled
        btnSignUp.isUserInteractionEnabled = true
        
        // add corner radius
        btnSignUp.layer.cornerRadius = 8
        
        // make password secured
        txtPassword.isSecureTextEntry = true
        
        // - set login label
        let attributedText = NSMutableAttributedString()
        attributedText.addText("Login", size: 17, bold: false, color: .darkGray, background: nil, addUnderline: true)
        lblLogin.attributedText = attributedText
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoLogin))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        lblLogin.addGestureRecognizer(tap)
        lblLogin.isUserInteractionEnabled = true
        
        // autohidekeyboard
        autoHideKeyboard()
    }
    
    @objc func gotoLogin() {
        if let parentVC = parent as? MainViewController {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            parentVC.updateView(vc: vc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parentVC = parent as? MainViewController {
            parentVC.btnLogout.isHidden = true
        }
    }
    
    @IBAction func doSignup(_ sender: UIButton) {
        
        let username = txtUsername.text ?? ""
        let password = txtPassword.text ?? ""
        
        if username.isEmpty || password.isEmpty {
            formError(show: true)
            return
        }
        
        formError(show: false)
        
        btnSignUp.isUserInteractionEnabled = false
        lblLogin.isUserInteractionEnabled = false
        
        // - automatically hide keyboard
        if txtPassword.isFirstResponder {
            txtPassword.resignFirstResponder()
        }
        
        if txtUsername.isFirstResponder {
            txtUsername.resignFirstResponder()
        }
        
        DataManager.shared.registerUser(username: username, password: password)
        .done { response in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.redirectChatPage()
            }
        }
        .catch { error in
            debugPrint("error: \(error)")
            self.formError(show: true)
        }
        .finally {
            self.btnSignUp.isUserInteractionEnabled = true
            self.lblLogin.isUserInteractionEnabled = true
        }
    }
    
    private func formError(show: Bool) {
        if show {
            lblPasswordError.text = "Value is incorrect"
            lblUsernameError.text = "Value is incorrect"
            lblPasswordErrorHeight.constant = 21
            lblUsernameErrorHeight.constant = 21
        } else {
            lblUsernameErrorHeight.constant = 0
            lblPasswordErrorHeight.constant = 0
        }
        view.layoutIfNeeded()
    }
}

extension UIViewController {
    func autoHideKeyboard(cancelTouchesInView cancel: Bool = false) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = cancel
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
