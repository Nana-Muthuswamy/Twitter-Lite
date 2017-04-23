//
//  SideBarViewController.swift
//  TwitterLite
//
//  Created by Nana on 4/21/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class SideBarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var sideBarController: AppSideBarController?
    var sideBarItemControllers: Array<UIViewController> = []
    let sideBartItemLabels = ["Profile", "Timeline", "Mentions", "Accounts"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Instantiate content view controllers
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        sideBarItemControllers.append(storyboard.instantiateViewController(withIdentifier: "ProfileNavController"))
        sideBarItemControllers.append(storyboard.instantiateViewController(withIdentifier: "TimelineNavController"))
        sideBarItemControllers.append(storyboard.instantiateViewController(withIdentifier: "MentionsNavController"))
        sideBarItemControllers.append(storyboard.instantiateViewController(withIdentifier: "TimelineNavController"))

        // Set the initial content view controller to logged in user's Profile view controller
        sideBarController?.setContentViewController(sideBarItemControllers[1])
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideBarItemControllers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "SideBarItemCell")!

        let sideBarItemLabel = tableCell.viewWithTag(1) as! UILabel
        sideBarItemLabel.text = sideBartItemLabels[indexPath.row]

        return tableCell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0, 1, 2, 3:
            sideBarController?.setContentViewController(sideBarItemControllers[indexPath.row])
        default:
            break
        }
    }
}
