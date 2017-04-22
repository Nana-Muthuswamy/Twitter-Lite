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
            emptyTweetsView = (tweets.count == 0)
            DispatchQueue.main.async {[weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    private var emptyTweetsView = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Navigation items
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"Compose")!, style: .plain, target: self, action: #selector(composeTweet(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut(_:)))



        // Setup table view attributes
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 94

        let tweetCellViewNib = UINib(nibName: "TweetTableViewCell", bundle: nil)
        tableView.register(tweetCellViewNib, forCellReuseIdentifier: "TweetTableViewCell")
        let emptyTweetsCellViewNib = UINib(nibName: "EmptyTweetsTableViewCell", bundle: nil)
        tableView.register(emptyTweetsCellViewNib, forCellReuseIdentifier: "EmptyTweetsTableViewCell")

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

    @IBAction func composeTweet(_ sender: Any) {
        performSegue(withIdentifier: "PresentComposeTweetView", sender: self)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (emptyTweetsView ? 1 : tweets.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if emptyTweetsView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTweetsTableViewCell") as! EmptyTweetsTableViewCell
            cell.message = Message(title: "Nothing to see here. Yet.", body: "From Retweets to likes and a whole lot more, this is where all the action happens about your Tweets and followers. You'll like it here.")

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
            cell.delegate = self
            cell.model = tweets[indexPath.row]

            return cell
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath) as? TweetTableViewCell
        performSegue(withIdentifier: "ShowTweetDetailsView", sender: cell)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if emptyTweetsView {
            return 600
        } else {
            return UITableViewAutomaticDimension
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowTweetDetailsView" {
            let tweetDetailsVC = segue.destination as! TweetDetailsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            tweetDetailsVC.tweet = tweets[indexPath.row]

        } else if segue.identifier == "PresentComposeTweetView" {
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
