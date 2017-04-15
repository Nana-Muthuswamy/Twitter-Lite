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

    @IBAction func login(_ sender: Any) {

        NetworkManager.shared.login { (user, error) in

            let alertMsg: String?

            if (user != nil && error == nil) {
                print("Login completed")
                DispatchQueue.main.async {[weak self] in
                    self?.performSegue(withIdentifier: "ShowTweetsView", sender: self)
                }
            } else {
                print("Login failed: \(String(describing: error?.localizedDescription))")

                switch error! {
                case .failure(let errMsg): alertMsg = errMsg
                case .invalidData(_): alertMsg = "Authentication failed or unable to fetch user info."
                }

                let alert = UIAlertController(title: "Login Failed", message: alertMsg, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

