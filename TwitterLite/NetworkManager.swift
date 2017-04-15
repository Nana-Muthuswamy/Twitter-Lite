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

class NetworkManager: BDBOAuth1SessionManager {

    // Singleton Shared Instance
    static let shared: NetworkManager! = NetworkManager(baseURL: URL(string: "https://api.twitter.com")! , consumerKey: "ImQ10TZvag9Qy6f05yWqHQlF8", consumerSecret: "BGgvmkWBGAeSM5yKZNZ7sGiHbZ1ObdaAJptSkC3cVBeDqKFZb3")

    var loginCompletionHandler: ((User?, NetworkAPIError?) -> Void)!

    // MARK: Login Utils
    func login(completion: ((User?, NetworkAPIError?) -> Void)?) {

        // Hold the completion handler
        loginCompletionHandler = completion

        NetworkManager.shared?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterlite://login") , scope: nil, success: {[weak self] (authCredential) in

            if let requestToken = authCredential?.token {
                print("Request Token: \(requestToken)")
                UIApplication.shared.open(URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken)")!, options: [:], completionHandler: nil)
            } else {
                print("Request Token is Empty!")
                self?.loginCompletionHandler(nil, NetworkAPIError.failure("Request token not fetched"))
            }

        }, failure: {[weak self] (error) in
            print("Error fetching request token: \(String(describing: error))")
            self?.loginCompletionHandler(nil, NetworkAPIError.failure(error?.localizedDescription))
        })
    }

    func handle(url: URL) {

        if let queryStr = url.query, let authCredential = BDBOAuth1Credential(queryString: queryStr) {

            NetworkManager.shared.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: authCredential, success: {[weak self] (authCredential) in

                if let accessToken = authCredential?.token {
                    print("Access Token: \(accessToken)")

                    NetworkManager.shared.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task, result) in

                        if let userDict = result as? Dictionary<String, Any> {
                            let user = User(dictionary: userDict)

                            print("User Account credentials:")
                            print("Name: \(user.name!)")
                            print("Screen Name: \(user.screenName!)")
                            print("Description: \(user.tagline!)")
                            print("Profile Image: \(user.profileURL!)")

                            // Update the current user
                            User.currentUser = user

                            self?.loginCompletionHandler(user, nil)

                        } else {
                            self?.loginCompletionHandler(nil, NetworkAPIError.invalidData(result))
                        }

                    }, failure: { (task, error) in
                        print("Error fetching user account credentials")
                        self?.loginCompletionHandler(nil, NetworkAPIError.failure(error.localizedDescription))
                    })

                } else {
                    print("Access token is empty")
                    self?.loginCompletionHandler(nil, NetworkAPIError.failure("Access token not fetched"))
                }

            }, failure: {[weak self] (error) in
                print("Error fetching access token: \(String(describing: error))")
                self?.loginCompletionHandler(nil, NetworkAPIError.failure(error?.localizedDescription))
            })

        }
    }

    // MARK: Fetch User Details

}
