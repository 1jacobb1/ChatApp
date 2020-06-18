//
//  IndexViewController.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/16/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit

class IndexViewController: UIViewController {
    
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignup.layer.cornerRadius = 8
        btnLogin.layer.cornerRadius = 8
    }

    @IBAction func gotoPage(_ sender: UIButton) {
        if let del = UIApplication.shared.delegate as? AppDelegate {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let main = sb.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            // - sign up page
            if sender.tag == 0 {
                let signUpVc = sb.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                main.useControllerOnLoad = signUpVc
                del.goToPage(page: main)
            // - login page
            } else if sender.tag == 1 {
                let loginVc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                main.useControllerOnLoad = loginVc
                del.goToPage(page: main)
            }
        }
    }
}
