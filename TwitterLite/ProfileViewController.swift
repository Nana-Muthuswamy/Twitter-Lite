//
//  ProfileViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/22/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class ProfileViewController: TimelineViewController {

    var user = User.currentUser!

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)?[0] as! ProfileHeaderView
        headerView.profile = user

        tableView.tableHeaderView = headerView
    }

}
