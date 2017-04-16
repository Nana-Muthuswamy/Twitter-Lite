//
//  TweetTableViewCell.swift
//  TwitterLite
//
//  Created by Nana on 4/15/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!

    var model: Tweet! {
        didSet {

            if let url = model.user?.profileURL {
                profileImageView.setImageWith(url)
            }
            nameLabel.text = model.user?.name
            screenNameLabel.text = model.user?.screenName
            timestampLabel.text = "10m"
            tweetTextLabel.text = model.text
            retweetCountLabel.text = "\(model.retweetCount)"
            favoriteCountLabel.text = "\(model.favoritesCount)"
        }
    }
}
