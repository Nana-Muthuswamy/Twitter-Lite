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

        NetworkManager.shared.login { (error) in
            if (error != nil) {
                print("Login completed")
            } else {
                print("Login failed: \(error)")
            }
        }
    }

}

