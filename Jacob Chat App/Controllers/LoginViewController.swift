//
//  LoginViewController.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/17/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var lblUsernameError: UILabel!
    @IBOutlet weak var lblUsernameErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblPasswordErrorHeight: NSLayoutConstraint!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblSignup: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ensure form error hidden
        formError(show: false)
        
        // ensure buttons are enabled
        btnLogin.isUserInteractionEnabled = true
        
        // make password secured
        txtPassword.isSecureTextEntry = true
        
        // - set corner radius
        btnLogin.layer.cornerRadius = 8
        
        // - set signup label
        let attributedText = NSMutableAttributedString()
        attributedText.addText("Sign up", size: 17, bold: false, color: .darkGray, background: nil, addUnderline: true)
        lblSignup.attributedText = attributedText
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoSingup))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        lblSignup.addGestureRecognizer(tap)
        lblSignup.isUserInteractionEnabled = true
        
        // autohidekeyboard
        autoHideKeyboard()
    }
    
    @objc func gotoSingup() {
        if let parentVC = parent as? MainViewController {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            parentVC.updateView(vc: vc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parentVC = parent as? MainViewController {
            parentVC.btnLogout.isHidden = true
        }
    }
    
    @IBAction func doLogin(_ sender: UIButton) {
        
        let username = txtUsername.text ?? ""
        let password = txtPassword.text ?? ""
        
        if username.isEmpty || password.isEmpty {
            formError(show: true)
            return
        }
        
        formError(show: false)
        
        lblSignup.isUserInteractionEnabled = false
        btnLogin.isUserInteractionEnabled = false
        
        // - automatically hide keyboard
        if txtPassword.isFirstResponder {
            txtPassword.resignFirstResponder()
        }
        
        if txtUsername.isFirstResponder {
            txtUsername.resignFirstResponder()
        }
        
        DataManager.shared.loginUser(username: username, password: password)
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
            self.lblSignup.isUserInteractionEnabled = true
            self.btnLogin.isUserInteractionEnabled = true
        }
    }
    
    private func formError(show: Bool) {
        if show {
            lblUsernameError.text = "Value is incorrect"
            lblPasswordError.text = "Value is incorrect"
            lblUsernameErrorHeight.constant = 21
            lblPasswordErrorHeight.constant = 21
        } else {
            lblUsernameErrorHeight.constant = 0
            lblPasswordErrorHeight.constant = 0
        }
        view.layoutIfNeeded()
    }
}

extension NSMutableAttributedString {
    
    @discardableResult func addText(_ text: String, size: CGFloat = 16, bold: Bool = false, color: UIColor? = nil, background: UIColor? = nil, addUnderline: Bool = false) -> NSMutableAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [:]
        
        if bold {
            attrs[NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue)] = UIFont.boldSystemFont(ofSize: size)
        } else {
            attrs[NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue)] = UIFont.systemFont(ofSize: size)
        }
        
        if let textColor = color {
            attrs[NSAttributedString.Key.foregroundColor] = textColor
        }
        
        if let bColor = background {
            attrs[NSAttributedString.Key.backgroundColor] = bColor
        }
        
        if addUnderline {
            attrs[NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue)] = NSUnderlineStyle.single.rawValue
            attrs[NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineColor.rawValue)] = UIColor.darkGray
        }

        let attributedString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(attributedString)
        return self
    }
}
