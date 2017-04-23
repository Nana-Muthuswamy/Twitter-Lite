//
//  ProfileViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/22/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class ProfileViewController: TweetsViewController {

    var user = User.currentUser!

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)?[0] as! ProfileHeaderView
        headerView.profile = user

        tableView.tableHeaderView = headerView

        // Navigation item customization based on access point
        if (navigationController?.viewControllers.first != self) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(backButtonPressed))
        }
    }

    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    override func loadData() {
        
        NetworkManager.shared.fetchTimeline(forId: user.idStr, completion: { [weak self] (results, error) in

            self?.refreshControl?.endRefreshing()

            if error == nil && results != nil {
                self?.tweets = results!
            } else if error != nil {

                let alertTitle: String
                let alertMsg: String

                switch error! {
                case .failure(let msg):
                    alertTitle = "Network Error"
                    alertMsg = msg ?? "Unable to fetch data."
                case .invalidData(_):
                    alertTitle = "Invalid Data"
                    alertMsg = "Unexpected data format returned"
                }

                self?.displayAlert(title: alertTitle, message: alertMsg, completion: nil)
            }
        })
    }

    override func tableViewCell(_ cell: TweetTableViewCell, displayProfileView: Bool) {
        // Avoid seguing to profile view for the currently viewing user
        if displayProfileView && (cell.model.tweetOwner?.idStr != user.idStr) {
            if let user = cell.model.tweetOwner {
                showProfileView(for: user)
            }
        }
    }
}
