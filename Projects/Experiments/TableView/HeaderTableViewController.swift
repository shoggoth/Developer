//
//  HeaderTableViewController.swift
//  Experiments
//
//  Created by Rich Henry on 04/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class HeaderTableViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet var headerTitleLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        Bundle.main.loadNibNamed("Header", owner: self, options: nil)

        headerTitleLabel.text = "Hello, World"

        tableView.tableHeaderView = headerView
    }
}

class IBConstructedHeaderTableViewController: UITableViewController {

    @IBOutlet var headerTitleLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        headerTitleLabel.text = "Hello, World"
    }
}
