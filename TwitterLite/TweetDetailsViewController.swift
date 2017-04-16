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

    var tweet: Tweet!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Tweet: \(tweet)")

        if let tweetInfo = tweet {

            if let url = tweetInfo.user?.profileURL {
                profileImageView.setImageWith(url)
            }

            nameLabel.text = tweetInfo.user?.name
            screenNameLabel.text = tweetInfo.user?.screenName
            tweetTextLabel.text = tweetInfo.text
            timestampLabel.text = tweetInfo.timeStamp?.readableValue
            retweetsCountLabel.text = String(format: "%d", tweetInfo.retweetCount)
            favoritesCountLabel.text = String(format: "%d", tweetInfo.favoritesCount)

            replyButton.isSelected = false
            retweetButton.isSelected = tweetInfo.retweeted
            favoriteButton.isSelected = tweetInfo.favorited
        }
    }

    @IBAction func retweet(_ sender: FaveButton) {
    }

    @IBAction func favorite(_ sender: FaveButton) {
        NetworkManager.shared.favorite(tweetID: tweet.idStr, favorite: sender.isSelected) { [weak self] (tweet, error) in
            if error == nil {
                print(sender.isSelected ? "Favorited!" : "UnFavorited")
                self?.tweet.favorited = sender.isSelected
            } else {
                self?.displayAlert(title: "Unable to Perform Operation", message: error?.localizedDescription ?? "Remote API failed due to unknown reason.")
                self?.executeOnMain({self?.favoriteButton.isSelected = (sender.isSelected ? false : true)})
            }

            self?.executeOnMain({self?.favoritesCountLabel.text = String(format: "%d", self?.tweet.favoritesCount ?? 0)})
        }
    }

    // MARK: - Utils

    fileprivate func displayAlert(title: String, message: String, completion: (() -> Void)? = nil) {

        DispatchQueue.main.async {[weak self] in
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion?()
            }))

            self?.present(alertVC, animated: true, completion: nil)
        }
    }

    fileprivate func executeOnMain(_ block: (() -> Void)?) {
        DispatchQueue.main.async {
            block?()
        }
    }
}
