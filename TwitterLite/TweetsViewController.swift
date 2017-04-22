//
//  TweetsViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/15/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class TweetsViewController: UITableViewController {

    var tweets = Array<Tweet>() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup title view
        navigationItem.titleView = UIImageView(image: UIImage(named: "TwitterIcon"))

        // Setup table view attributes
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 94

        let tableCellViewNib = UINib(nibName: "TweetTableViewCell", bundle: nil)
        tableView.register(tableCellViewNib, forCellReuseIdentifier: "TweetTableViewCell")

        // Setup UIRefresh
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)

        // Load twitter home time line of tweets...
        loadData()
    }

    // MARK: - Data

    func loadData() {
        // default implementation does nothing, need to be overriden by sub classes
    }

    // MARK: - Action Methods

    @IBAction func signOut(_ sender: Any) {
        NetworkManager.shared.logout()
        performSegue(withIdentifier: "unwindToLoginView", sender: self)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
        cell.delegate = self
        cell.model = tweets[indexPath.row]

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell
        performSegue(withIdentifier: "ShowTweetDetailsView", sender: cell)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowTweetDetailsView" {
            let tweetDetailsVC = segue.destination as! TweetDetailsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            tweetDetailsVC.tweet = tweets[indexPath.row]

        } else if segue.identifier == "ShowComposeTweetView" {
            let composeTweetVC = (segue.destination as! UINavigationController).viewControllers.first as! ComposeTweetViewController
            composeTweetVC.delegate = self
        }
    }

    // MARK: - Utils

    func displayAlert(title: String, message: String, completion: (() -> Void)?) {

        executeOnMain { 
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion?()
            }))

            self.present(alertVC, animated: true, completion: nil)
        }
    }

    func executeOnMain(_ block: (() -> Void)?) {
        DispatchQueue.main.async {
            block?()
        }
    }

}

extension TweetsViewController: ComposeTweetViewControllerDelegate {
    func updateTimeline(with newTweet: Tweet) {
        tweets.insert(newTweet, at: 0)
        executeOnMain({self.tableView.reloadData()})
    }
}

extension TweetsViewController: TweetTableViewCellDelegate {

    func tableViewCell(_ cell: TweetTableViewCell, didRetweet: Bool) {

        let indexPath = tableView.indexPath(for: cell)!
        let tweet = tweets[indexPath.row]

        NetworkManager.shared.retweet(tweetID: tweet.idStr, retweet: didRetweet) {[weak self] (_, error) in

            if error == nil {
                tweet.retweeted = didRetweet
                self?.executeOnMain({self?.tableView.reloadData()})
            } else {
                self?.displayAlert(title: "Unable to Perform Operation", message: error?.localizedDescription ?? "Remote API failed due to unknown reason.", completion: nil)
            }
        }
    }

    func tableViewCell(_ cell: TweetTableViewCell, didFavorite: Bool) {

        let indexPath = tableView.indexPath(for: cell)!
        let tweet = tweets[indexPath.row]

        NetworkManager.shared.favorite(tweetID: tweet.idStr, favorite: didFavorite) { [weak self] (_, error) in

            if error == nil {
                tweet.favorited = didFavorite
                self?.executeOnMain({self?.tableView.reloadData()})
            } else {
                self?.displayAlert(title: "Unable to Perform Operation", message: error?.localizedDescription ?? "Remote API failed due to unknown reason.", completion: nil)
            }
        }
    }
}
