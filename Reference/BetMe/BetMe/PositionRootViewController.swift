//
//  PositionRootViewController.swift
//  BetMe
//
//  Created by Rich Henry on 24/04/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

private var titlesAndKeys = [("Market ID", "market_id"), ("Best Unmatched", "best_unmatched_position"), ("Unmatched", "position_unmatched"), ("Best Matched", "best_matched_position"), ("Matched", "position_matched"), ("Liability", "position_matched")]

class PositionRootViewController : UIViewController {

    @IBOutlet var sectionHeaderViews: [UIView]?
    @IBOutlet var compactHeaderButtons: [UIButton]!
    @IBOutlet var regularHeaderButtons: [UIButton]!

    @IBOutlet weak var dataSource: SubscriptionDataSource!

    @IBOutlet weak var disclosureButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    private var headerDisclosed = false
    private let sectionHeaderHeight: CGFloat = 88.0

    private let session = BetMeServerSession.sharedInstance

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        Bundle.main.loadNibNamed("PositionsSectionHeader", owner: self, options: nil)
        dataSource.sectionHeaderViews = sectionHeaderViews

        for (index, button) in compactHeaderButtons.enumerated() {

            button.setTitle(titlesAndKeys[index].0, for: .normal)
        }

        headerHeightConstraint.constant = 44

        dataSource.tableCellConfigBlock = { cell, data in

            (cell as? PositionCell)?.configure(withData: data)
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        dataSource.subscribe(withNotificationKey: positionsChangedNotificationKey)

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {

        dataSource.unsubscribe(withNotificationKey: positionsChangedNotificationKey)

        super.viewWillDisappear(animated)
    }

    // MARK: Actions

    private let tableHeaderOpenHeight : CGFloat = 88
    private let tableHeaderClosedHeight : CGFloat = 44

    @IBAction func disclosureButtonTapped(_ sender: Any) {

        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.23) {

            if !self.headerDisclosed {

                self.disclosureButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
                self.headerHeightConstraint.constant = self.tableHeaderOpenHeight

            } else {

                self.disclosureButton.imageView?.transform = .identity
                self.headerHeightConstraint.constant = self.tableHeaderClosedHeight
            }

            self.view.layoutIfNeeded()

            self.headerDisclosed = !self.headerDisclosed
        }
    }
    
    @IBAction func headerButtonTapped(_ sender: UIButton) {

        print("Button \(sender.tag) tapped")
    }
}

// MARK: - Cell

class PositionCell : UITableViewCell {
    
    @IBOutlet var compactLabels: [UILabel]!
    @IBOutlet var regularLabels: [UILabel]!

    func configure(withData data: [String : Any]) {

        for (index, label) in compactLabels.enumerated() {

            label.text = data[titlesAndKeys[index].1] as? String
        }
    }
}
