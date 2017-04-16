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
            retweetButton.isSelected = false
            favoriteButton.isSelected = false
        }
    }

    @IBAction func retweet(_ sender: FaveButton) {
    }

    @IBAction func favorite(_ sender: FaveButton) {
    }
}
