//
//  NetworkManager.swift
//  TwitterLite
//
//  Created by Nana on 4/14/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import BDBOAuth1Manager

enum NetworkAPIError: Error {
    case invalidData(Any?)
    case failure(String?)
}

fileprivate let userAccountURL = "1.1/account/verify_credentials.json"
fileprivate let timelineURL = "1.1/statuses/home_timeline.json"
fileprivate let mentionsURL = "1.1/statuses/mentions_timeline.json"
fileprivate let retweetURL = "1.1/statuses/retweet/<tweetId>.json"
fileprivate let unRetweetURL = "1.1/statuses/unretweet/<tweetId>.json"
fileprivate let favoriteURL = "1.1/favorites/create.json"
fileprivate let unFavoriteURL = "1.1/favorites/destroy.json"
fileprivate let updateStatusURL = "1.1/statuses/update.json"
fileprivate let statusURL = "1.1/statuses/show/<tweetId>.json?include_my_retweet=1"


class NetworkManager: BDBOAuth1SessionManager {

    // Singleton Shared Instance
    static let shared: NetworkManager! = NetworkManager(baseURL: URL(string: "https://api.twitter.com")! , consumerKey: "ImQ10TZvag9Qy6f05yWqHQlF8", consumerSecret: "BGgvmkWBGAeSM5yKZNZ7sGiHbZ1ObdaAJptSkC3cVBeDqKFZb3")

    var loginCompletionHandler: ((User?, NetworkAPIError?) -> Void)!

    // MARK: - Login & Logout

    func login(completion: @escaping ((User?, NetworkAPIError?) -> Void)) {

        // Hold the completion handler
        loginCompletionHandler = completion

        // Deauthorize (recommended approach due to OAuth bug)
        deauthorize()

        // Fetch Request Token for user
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterlite://login") , scope: nil, success: {[weak self] (authCredential) in

            if let requestToken = authCredential?.token {
                // Load Authorize URL in default browser
                UIApplication.shared.open(URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken)")!, options: [:], completionHandler: nil)
            } else {
                self?.loginCompletionHandler(nil, NetworkAPIError.failure("Request token not fetched"))
            }

        }, failure: {[weak self] (error) in
            self?.loginCompletionHandler(nil, NetworkAPIError.failure(error?.localizedDescription))
        })
    }

    func handle(url: URL) {

        if let queryStr = url.query, let authCredential = BDBOAuth1Credential(queryString: queryStr) {

            // Fetch Access Token for the authorized user
            fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: authCredential, success: {[weak self] (authCredential) in

                if (authCredential?.token) != nil {

                    self?.fetchUserAccount(completion: (self?.loginCompletionHandler)!)

                } else {
                    self?.loginCompletionHandler(nil, NetworkAPIError.failure("Access token not fetched"))
                }
                
            }, failure: {[weak self] (error) in
                self?.loginCompletionHandler(nil, NetworkAPIError.failure(error?.localizedDescription))
            })

        }
    }

    func logout() {
        // Clear the current user
        User.currentUser = nil
        // Deauthorize the app
        deauthorize()
    }

    // MARK: - Fetch Methods

    func fetchUserAccount(completion: @escaping ((User?, NetworkAPIError?) -> Void)) {

        // Fetch user's account profile
        self.get(userAccountURL, parameters: nil, progress: nil, success: { (task, response) in

            if let userDict = response as? Dictionary<String, Any> {
                let user = User(dictionary: userDict)

                print("Name: \(user.name!)")
                print("Screen Name: \(user.screenName!)")
                print("Description: \(user.tagline!)")
                print("Profile Image: \(user.profileURL!)")

                // Update the current user
                User.currentUser = user

                // Successful login completion
                completion(user, nil)

            } else {
                completion(nil, NetworkAPIError.invalidData(response))
            }

        }, failure: { (task, error) in
            completion(nil, NetworkAPIError.failure(error.localizedDescription))
        })
    }

    func fetchHomeTimeline(completion: @escaping (Array<Tweet>?, NetworkAPIError?) -> Void) {

        get(timelineURL, parameters: nil, progress: nil, success: { (task, response) in
            print("HomeTimeLine 1: \(String(describing: response))")

            var tweets = Array<Tweet>()

            if let arrayOfTweets = response as? Array<Dictionary<String, Any>> {
                tweets = Tweet.tweets(dictionaries: arrayOfTweets)
                completion(tweets, nil)
            } else {
                completion(nil, NetworkAPIError.invalidData(response))
            }

        }) { (task, error) in
            completion(nil, NetworkAPIError.failure(error.localizedDescription))
        }
    }

    func fetchMentionsTimeline(completion: @escaping (Array<Tweet>?, NetworkAPIError?) -> Void) {

        get(mentionsURL, parameters: nil, progress: nil, success: { (task, response) in
            print("HomeTimeLine 1: \(String(describing: response))")

            var tweets = Array<Tweet>()

            if let arrayOfTweets = response as? Array<Dictionary<String, Any>> {
                tweets = Tweet.tweets(dictionaries: arrayOfTweets)
                completion(tweets, nil)
            } else {
                completion(nil, NetworkAPIError.invalidData(response))
            }

        }) { (task, error) in
            completion(nil, NetworkAPIError.failure(error.localizedDescription))
        }
    }

    // MARK: - Retweeting

    func retweet(tweetID: String, retweet: Bool, completion: @escaping (Tweet?, Error?) -> ()) {

        let endPoint: String

        if retweet {
            endPoint = retweetURL.replacingOccurrences(of: "<tweetId>", with: tweetID)
        } else {
            endPoint = unRetweetURL.replacingOccurrences(of: "<tweetId>", with: tweetID)
        }

        post(endPoint, parameters: nil, progress: nil, success: { (task, response) in

            if let responseDict = response as? Dictionary<String, Any> {
                completion(Tweet(dictionary: responseDict), nil)
            } else {
                completion(nil, NetworkAPIError.invalidData(response))
            }
        }, failure: { (task, error) in
            completion(nil, NetworkAPIError.failure(error.localizedDescription))
        })
    }


    // MARK: - Favoriting

    func favorite(tweetID: String, favorite: Bool, completion: @escaping (Tweet?, Error?) -> ()) {

        let params = ["id" : tweetID]

        let endpoint : String

        if favorite {
            endpoint = favoriteURL
        }else{
            endpoint = unFavoriteURL
        }

        post(endpoint, parameters: params, progress: nil, success: { (task, response) in
            if let tweetDict = response as? Dictionary<String, Any> {
                let tweet = Tweet(dictionary: tweetDict)
                completion(tweet, nil)
            } else {
                completion(nil, NetworkAPIError.invalidData(response))
            }
        }) { (task, error) in
            completion(nil, NetworkAPIError.failure(error.localizedDescription))
        }
    }

    // MARK: - Tweeting

    func tweet(text: String, replyToStatusId: String?, completion: @escaping (Tweet?, Error?) -> ()) {

        var params = ["status" : text]

        if replyToStatusId != nil {
            params["in_reply_to_status_id"] = replyToStatusId
        }

        post(updateStatusURL, parameters: params, progress: nil, success: { (_, response) in
            if let responseDict = response as? Dictionary<String, Any> {
                completion(Tweet(dictionary: responseDict), nil)
            } else {
                completion(nil, NetworkAPIError.invalidData(response))
            }
        }) { (_, error) in
            completion(nil, NetworkAPIError.failure(error.localizedDescription))
        }
    }
}
