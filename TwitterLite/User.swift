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

    var dictionary: Dictionary<String, Any>!

    init(dictionary: Dictionary<String, Any>) {

        // Persist input dictionary for future use
        self.dictionary = dictionary

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

    private static var _currentUser: User?

    static var currentUser: User? {
        get {

            if _currentUser == nil {
                // TDO: Should use DispatchSemaphore to initiate login and fetch user details when not persisted
                if let userData = UserDefaults.standard.data(forKey: "currentUser") {
                    let userDict = try! JSONSerialization.jsonObject(with: userData, options: []) as! Dictionary<String, Any>
                    _currentUser = User(dictionary: userDict)
                }
            }

            return _currentUser
        }
        set(newUser) {

            _currentUser = newUser

            let defaults = UserDefaults.standard

            if _currentUser == nil {
                defaults.set(nil, forKey: "currentUser")
            } else {
                let userData = try! JSONSerialization.data(withJSONObject: newUser?.dictionary as Any, options: [])
                defaults.set(userData, forKey: "currentUser")
            }

            defaults.synchronize()
        }
    }


}
