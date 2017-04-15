//
//  LoginViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/14/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if User.currentUser != nil {
            performSegue(withIdentifier: "ShowTweetsView", sender: self)
        }
    }

    @IBAction func login(_ sender: Any) {

        NetworkManager.shared.login { (user, error) in

            let alertMsg: String?

            if (user != nil && error == nil) {
                DispatchQueue.main.async {[weak self] in
                    self?.performSegue(withIdentifier: "ShowTweetsView", sender: self)
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
}

