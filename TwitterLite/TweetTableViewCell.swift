//
//  TweetTableViewCell.swift
//  TwitterLite
//
//  Created by Nana on 4/15/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit
import FaveButton

protocol TweetTableViewCellDelegate: class {
    func tableViewCell(_ cell: TweetTableViewCell, didRetweet: Bool)
    func tableViewCell(_ cell: TweetTableViewCell, didFavorite: Bool)
    func tableViewCell(_ cell: TweetTableViewCell, displayProfileView: Bool)
}

class TweetTableViewCell: UITableViewCell {

    weak var delegate: TweetTableViewCellDelegate?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var retweetButton: FaveButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: FaveButton!
    @IBOutlet weak var replyButton: FaveButton!

    @IBOutlet weak var retweetUserNameLabel: UILabel!
    @IBOutlet weak var retweetedStackViewHeightConstraint: NSLayoutConstraint!

    var model: Tweet! {
        didSet {

            if model.retweeted {
                retweetUserNameLabel.text = model.retweetedUserName
                retweetedStackViewHeightConstraint.constant = 20.0

            } else {
                retweetUserNameLabel.text = nil
                retweetedStackViewHeightConstraint.constant = 0.0
            }

            if let url = model.tweetOwner?.profileURL {
                profileImageView.setImageWith(url)
            }
            
            nameLabel.text = model.tweetOwner?.name
            screenNameLabel.text = model.tweetOwner?.screenName
            timestampLabel.text = model.timeStamp?.relativeValue
            tweetTextLabel.text = model.text
            retweetCountLabel.text = String(format: "%d", model.retweetCount)
            favoriteCountLabel.text = String(format: "%d", model.favoritesCount)
            retweetButton.isSelected = model.retweeted
            favoriteButton.isSelected = model.favorited
            replyButton.isSelected = false
        }
    }

    @IBAction func retweet(_ sender: FaveButton) {
        delegate?.tableViewCell(self, didRetweet: sender.isSelected)
    }

    @IBAction func favorite(_ sender: FaveButton) {
        delegate?.tableViewCell(self, didFavorite: sender.isSelected)
    }

    @IBAction func tapProfileImageView(_ sender: UITapGestureRecognizer) {
    }

}
