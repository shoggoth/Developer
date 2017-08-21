//
//  TableRootViewController.swift
//  TableView
//
//  Created by Rich Henry on 03/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class TableRootViewController: UITableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
    }

    // MARK: Appearance

    override var preferredStatusBarStyle: UIStatusBarStyle {

        return .default
        //return .lightContent
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToRoot(sender: UIStoryboardSegue) {

        //print("And relax \(sender.source)")
    }
}

