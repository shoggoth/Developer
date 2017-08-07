//
//  ColumnarTableViewController.swift
//  Experiments
//
//  Created by Rich Henry on 07/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class ColumnarTableViewController: UITableViewController {

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

                print("Installed = \(dataCell.dataLabels[index].isInstalled())")

                dataCell.dataLabels[index].text = value
            }
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

class ColumnCell : UITableViewCell {

    @IBOutlet var dataLabels: [UILabel]!
}

private extension UIView {

    func isInstalled() -> Bool { return self.superview != nil }
}
