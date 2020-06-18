//
//  MainViewController.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/17/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnLogout: UIButton!
    
    var currentChildVC: UIViewController?
    var useControllerOnLoad: UIViewController?
    
    /// MARK - set content controllers here
    // login page
    private lazy var loginVC: LoginViewController = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        return vc
    }()
    
    // signup page
    private lazy var signupVC: SignUpViewController = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        return vc
    }()
    
    private func add(asChildeVC vc: UIViewController) {
        currentChildVC = vc
        addChild(vc)
        viewContent.addSubview(vc.view)
        vc.view.frame = viewContent.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
    }
    
    private func remove(asChildVC vc: UIViewController) {
        vc.willMove(toParent: self)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let useVC = useControllerOnLoad {
            updateView(vc: useVC)
        }
    }
    
    func updateView(vc: UIViewController) {
        if let currVC = currentChildVC {
            remove(asChildVC: currVC)
        }
        add(asChildeVC: vc)
    }
}
