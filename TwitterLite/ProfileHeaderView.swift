//
//  ProfileHeaderView.swift
//  TwitterLite
//
//  Created by Nana on 4/22/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!

    var profile: User! {
        didSet {
            if profile != nil {

                if let url = profile.profileURL {
                    imageView.setImageWith(url)
                }
                nameLabel.text = profile.name
                screenNameLabel.text = profile.screenName
                tweetsCountLabel.text = String(format: "%d", profile.tweetsCount)
                followingCountLabel.text = String(format: "%d", profile.followingCount)
                followersCountLabel.text = String(format: "%d", profile.followersCount)
            }
        }
    }
}
