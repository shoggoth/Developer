//
//  ExpandingTableSectionViewController.swift
//  CloudKitViewer
//
//  Created by Richard Henry on 29/10/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class ExpandingTableSectionViewController: UITableViewController {

    var cells: [UITableViewCell] = []

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions

    @IBAction func addRowToSection(sender: UIButton) {

        tableView.beginUpdates()

        print("Expand it!")

        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)

        tableView.endUpdates()
    }

    // MARK: TableView overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 1 { return cells.count } else { return super.tableView(tableView, numberOfRowsInSection: section) }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 1 { return cells[indexPath.row] } else { return super.tableView(tableView, cellForRowAtIndexPath: indexPath) }
    }
}

class DemoCell : UITableViewCell {

}