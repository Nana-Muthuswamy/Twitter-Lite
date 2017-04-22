//
//  LoginViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/14/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if User.currentUser != nil {
            presentAppContainerController()
        }
    }

    // MARK: - Action Methods

    @IBAction func login(_ sender: Any) {

        NetworkManager.shared.login { (user, error) in

            let alertMsg: String?

            if (user != nil && error == nil) {
                DispatchQueue.main.async {[weak self] in
                    self?.presentAppContainerController()
                }
            } else {
                switch error! {
                case .failure(let errMsg): alertMsg = errMsg
                case .invalidData(_): alertMsg = "Authentication failed or unable to fetch user info."
                }

                let alert = UIAlertController(title: "Login Failed", message: alertMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func unwindToLoginView(segue: UIStoryboardSegue) {
        print("User Signed out")
    }

    // MARK: - Utils

    private func presentAppContainerController() {
        // Setup AppSideBarController's SideBarViewController and vice versa
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let appSideBarController = storyboard.instantiateViewController(withIdentifier: "AppSideBarController") as! AppSideBarController
        let sideBarVC = storyboard.instantiateViewController(withIdentifier: "SideBarViewController") as! SideBarViewController

        sideBarVC.sideBarController = appSideBarController
        appSideBarController.sideBarViewController = sideBarVC

        present(appSideBarController, animated: true, completion: nil)
    }
}

