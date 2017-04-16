//
//  TweetsViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/15/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class TweetsViewController: UITableViewController {

    fileprivate var tweets = Array<Tweet>() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup table view attributes
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 94

        // Load twitter home time line of tweets...
        NetworkManager.shared.fetchHomeTimeline { [weak self] (results, error) in
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

    // MARK: Action Methods

    @IBAction func signOut(_ sender: Any) {
        NetworkManager.shared.logout()
        performSegue(withIdentifier: "unwindToLoginView", sender: self)
    }

    // MARK UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
        cell.model = tweets[indexPath.row]

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Utils

    fileprivate func displayAlert(title: String, message: String, completion: (() -> Void)?) {

        DispatchQueue.main.async {[weak self] in
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion?()
            }))

            self?.present(alertVC, animated: true, completion: nil)
        }
    }
}
