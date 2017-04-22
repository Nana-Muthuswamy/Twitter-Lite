//
//  EmptyTweetsTableViewCell.swift
//  TwitterLite
//
//  Created by Nana on 4/22/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class EmptyTweetsTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    var message: Message! {
        didSet {
            headerLabel.text = message.title
            detailsLabel.text = message.body
        }
    }
}
