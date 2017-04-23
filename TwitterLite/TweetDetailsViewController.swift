//
//  TweetDetailsViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/16/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit
import FaveButton

class TweetDetailsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var replyButton: FaveButton!
    @IBOutlet weak var retweetButton: FaveButton!
    @IBOutlet weak var favoriteButton: FaveButton!

    @IBOutlet weak var retweetUserNameLabel: UILabel!
    @IBOutlet weak var retweetedStackViewHeightConstraint: NSLayoutConstraint!

    var tweet: Tweet!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Tweet: \(tweet)")

        if tweet.retweeted {
            retweetUserNameLabel.text = tweet.retweetedUserName
            retweetedStackViewHeightConstraint.constant = 20.0

        } else {
            retweetUserNameLabel.text = nil
            retweetedStackViewHeightConstraint.constant = 0.0
        }

        if let url = tweet.tweetOwner?.profileURL {
            profileImageView.setImageWith(url)
        }

        nameLabel.text = tweet.tweetOwner?.name
        screenNameLabel.text = tweet.tweetOwner?.screenName
        tweetTextLabel.text = tweet.text
        timestampLabel.text = tweet.timeStamp?.readableValue
        retweetsCountLabel.text = String(format: "%d", tweet.retweetCount)
        favoritesCountLabel.text = String(format: "%d", tweet.favoritesCount)

        replyButton.isSelected = false
        retweetButton.isSelected = tweet.retweeted
        favoriteButton.isSelected = tweet.favorited
    }

    // MARK: Action Methods

    @IBAction func retweet(_ sender: FaveButton) {

        NetworkManager.shared.retweet(tweetID: tweet.idStr, retweet: sender.isSelected) {[weak self] (_, error) in

            if error == nil {
                self?.tweet.retweeted = sender.isSelected
                self?.executeOnMain({
                    self?.retweetsCountLabel.text = String(format: "%d", self?.tweet.retweetCount ?? 0)
                    self?.retweetInfo(display: sender.isSelected)
                })
            } else {
                self?.executeOnMain({self?.retweetButton.isSelected = (sender.isSelected ? false : true)})
                self?.displayAlert(title: "Unable to Perform Operation", message: error?.localizedDescription ?? "Remote API failed due to unknown reason.")
            }
        }
    }

    @IBAction func favorite(_ sender: FaveButton) {

        NetworkManager.shared.favorite(tweetID: tweet.idStr, favorite: sender.isSelected) { [weak self] (_, error) in

            if error == nil {
                self?.tweet.favorited = sender.isSelected
                self?.executeOnMain({self?.favoritesCountLabel.text = String(format: "%d", self?.tweet.favoritesCount ?? 0)})
            } else {
                self?.executeOnMain({self?.favoriteButton.isSelected = (sender.isSelected ? false : true)})
                self?.displayAlert(title: "Unable to Perform Operation", message: error?.localizedDescription ?? "Remote API failed due to unknown reason.")
            }
        }
    }

    @IBAction func tapProfileName(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ShowProfileView", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfileView" {
            let destination = segue.destination as! ProfileViewController
            destination.user = tweet.tweetOwner!
        }
    }


    // MARK: - Utils

    fileprivate func displayAlert(title: String, message: String, completion: (() -> Void)? = nil) {

        executeOnMain { 
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion?()
            }))

            self.present(alertVC, animated: true, completion: nil)
        }
    }

    fileprivate func executeOnMain(_ block: (() -> Void)?) {
        DispatchQueue.main.async {
            block?()
        }
    }

    fileprivate func retweetInfo(display: Bool) {

        if display {
            self.retweetedStackViewHeightConstraint.constant = 20.0
            self.retweetUserNameLabel.text = User.currentUser?.name
        } else {
            self.retweetedStackViewHeightConstraint.constant = 0
            self.retweetUserNameLabel.text = nil
        }
    }
}
