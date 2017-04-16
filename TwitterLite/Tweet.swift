//
//  Tweet.swift
//  TwitterLite
//
//  Created by Nana on 4/15/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

class Tweet {

    var text: String?
    var timeStamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?

    init(dictionary: Dictionary<String, Any>) {

        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0

        if let dateStr = dictionary["created_dt"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timeStamp = dateFormatter.date(from: dateStr)
        }

        if let userDict = dictionary["user"] as? Dictionary<String,Any> {
            self.user = User(dictionary: userDict)
        }
    }

    class func tweets(dictionaries: Array<Dictionary<String, Any>>) -> Array<Tweet> {

        var tweets = Array<Tweet>()

        for aDict in dictionaries {
            tweets.append(Tweet(dictionary: aDict))
        }

        return tweets
    }

}
