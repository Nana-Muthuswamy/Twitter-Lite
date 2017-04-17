//
//  ComposeTweetViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/16/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {

    var sourceTweet: Tweet?
    var delegate: ComposeTweetViewControllerDelegate?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!

    @IBOutlet weak var tweetBarButton: UIBarButtonItem!
    @IBOutlet weak var tweetCharactersCountBarButton: UIBarButtonItem!

    let maxTweetTextCharacters: Int = 140

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup title view
        navigationItem.titleView = UIImageView(image: UIImage(named: "TwitterIcon"))

        // Disable Tweet button
        tweetBarButton.isEnabled = false

        // Setup view data
        if let user = User.currentUser {
            profileImageView.setImageWith(user.profileURL!)
            nameLabel.text = user.name
            screenameLabel.text = user.screenName
        }

        tweetTextView.becomeFirstResponder()
    }

    @IBAction func tweet(_ sender: UIBarButtonItem) {

        NetworkManager.shared.tweet(text: tweetTextView.text, replyToStatusId: sourceTweet?.idStr) {[weak self] (tweet, error) in

            if tweet != nil && error == nil {
                self?.delegate?.updateTimeline(with: tweet!)
                self?.dismiss(animated: true)
            } else {
                self?.displayAlert(title: "Unable to Perform Operation", message: error?.localizedDescription ?? "Remote API failed due to unknown reason.")
            }
        }

    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    //Mark: Textview Delegates

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return tweetTextView.text.characters.count + (text.characters.count - range.length) <= maxTweetTextCharacters
    }

    func textViewDidChange(_ textView: UITextView) {
        tweetCharactersCountBarButton.title = "\(maxTweetTextCharacters - tweetTextView.text.characters.count)"
        tweetBarButton.isEnabled = tweetTextView.text.characters.count > 0
    }

    // MARK: - Utils

    fileprivate func displayAlert(title: String, message: String, completion: (() -> Void)? = nil) {

        executeOnMain {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                completion?()
            }))

            self.present(alertVC, animated: true, completion: nil)
        }
    }

    fileprivate func executeOnMain(_ block: (() -> Void)?) {
        DispatchQueue.main.async {
            block?()
        }
    }
}

protocol ComposeTweetViewControllerDelegate: class {
    func updateTimeline(with newTweet: Tweet)
}
