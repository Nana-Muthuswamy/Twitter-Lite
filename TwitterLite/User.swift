//
//  User.swift
//  TwitterLite
//
//  Created by Nana on 4/15/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

class User {

    var name: String?
    var screenName: String?
    var profileURL: URL?
    var tagline: String?

    init(dictionary: Dictionary<String, Any>) {

        if let userName = dictionary["name"] as? String {
            name = userName
        }

        if let userScreenName = dictionary["screen_name"] as? String {
            screenName = userScreenName
        }

        if let profileURLPath = dictionary["profile_image_url"] as? String {
            profileURL = URL(string: profileURLPath)
        }

        if let userTagline = dictionary["description"] as? String {
            tagline = userTagline
        }
    }


}
