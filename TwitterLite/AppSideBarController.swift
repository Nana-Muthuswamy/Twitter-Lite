//
//  AppSideBarController.swift
//  TwitterLite
//
//  Created by Nana on 4/21/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class AppSideBarController: UIViewController {

    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    fileprivate var contentViewOriginalLeadingConstraintConst: CGFloat = 0
    fileprivate var leadingConstraintConstForSideBarOpen: CGFloat = 0
    fileprivate var leadingConstraintConstForSideBarClosed: CGFloat = 0

    var sideBarViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()

            sideBarViewController.view.frame = view.bounds
            sideBarView.addSubview(sideBarViewController.view)
        }
    }

    fileprivate var contentViewController: UIViewController! {
        // Book keeping before and after updating contentViewController
        willSet {
            if contentViewController != nil {
                discard(contentViewController)
            }
        }
        didSet {
            if contentViewController != nil {
                setup(contentViewController)
            }
        }
    }

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup constraint constant values for side bar positions
        leadingConstraintConstForSideBarOpen = view.frame.size.width - 100
        leadingConstraintConstForSideBarClosed = 0
    }

    // MARK: - Action methods

    @IBAction func panToSideBarView(_ sender: UIPanGestureRecognizer) {

        let translation = sender.translation(in: view)
        let velocity = sender.translation(in: view)

        // When panning from right to left while side bar is closed, do nothing!
        if velocity.x < 0 && contentViewLeadingConstraint.constant == leadingConstraintConstForSideBarClosed {
            return
        }

        if (sender.state == .began) {

            contentViewOriginalLeadingConstraintConst = contentViewLeadingConstraint.constant

        } else if (sender.state == .changed) {

            contentViewLeadingConstraint.constant = contentViewOriginalLeadingConstraintConst + translation.x

        } else if (sender.state == .ended) {

            if velocity.x > 0 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                    self.contentViewLeadingConstraint.constant = self.leadingConstraintConstForSideBarOpen
                    self.view.layoutIfNeeded()
                }, completion: nil)

            } else {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.contentViewLeadingConstraint.constant = self.leadingConstraintConstForSideBarClosed
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    // MARK: Content View Controller management

    func setContentViewController(_ newContentVC: UIViewController) {
        // Guard content view controller to hold only view controllers with valid associated view
        guard newContentVC.view != nil else {
            return
        }

        // When selecting Side Bar item, close the side bar before updating content view controller
        if contentViewLeadingConstraint.constant == leadingConstraintConstForSideBarOpen {
            UIView.animate(withDuration: 0.5, animations: { 
                self.contentViewLeadingConstraint.constant = self.leadingConstraintConstForSideBarClosed
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                DispatchQueue.main.async {
                    self.contentViewController = newContentVC
                }
            })
        } else {
            DispatchQueue.main.async {
                self.contentViewController = newContentVC
            }
        }
    }

    fileprivate func discard(_ currentContentViewController: UIViewController) {
        // Its a must to notify current content view controller before removing its view from content view
        currentContentViewController.willMove(toParentViewController: nil)
        // Remove current content view controller's view from contentView placeholder view
        currentContentViewController.view.removeFromSuperview()
        // Finally, remove the current content view controller from view controller hierarchy
        // this will implicitly invoke didMove(toParentViewController) with nil as parameter
        currentContentViewController.removeFromParentViewController()
    }

    fileprivate func setup(_ newContentViewController: UIViewController) {
        // Add the new content view controller to view controller hierarchy
        // this will implicitly invoke willMove(toParentViewController) with self as parameter
        addChildViewController(newContentViewController)
        // Set the frame and add newContentViewController's view to the content view placeholder
        let newContentView = newContentViewController.view!
        newContentView.frame = self.contentView.bounds
        contentView.addSubview(newContentView)
        // Its a must to notify new content view controller after adding its view to content view
        newContentViewController.didMove(toParentViewController: self)
    }

}
