//
//  MentionsViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/22/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class MentionsViewController: TweetsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Data

    override func loadData() {

        NetworkManager.shared.fetchMentionsTimeline { [weak self] (results, error) in

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
        }
    }
}
