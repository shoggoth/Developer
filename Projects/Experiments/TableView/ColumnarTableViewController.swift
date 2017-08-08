//
//  ColumnarTableViewController.swift
//  Experiments
//
//  Created by Rich Henry on 07/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

private let data = [["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "DataL", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
]

class ColumnarTableViewController: UITableViewController {

    override func viewDidLoad() {

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        // Configure the cell...
        if let dataCell = cell as? ColumnCell {

            let row = data[indexPath.row]

            for (index, value) in row.enumerated() {

                dataCell.dataLabels[index].text = value
            }
        }

        return cell
    }
}

class ColumnCell : UITableViewCell {

    @IBOutlet var dataLabels: [UILabel]!
}
