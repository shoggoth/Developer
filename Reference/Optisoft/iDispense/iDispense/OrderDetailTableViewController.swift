//
//  OrderDetailTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 20/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: Order detail table view controller
//
// Some spiel here about how this is the best table view controller that has ever been
// thought of for some of the time.
//

class OrderDetailTableViewController: UITableViewController {

    // MARK: Properties

    // UI General
    @IBOutlet weak var guidLabel:       UILabel!
    @IBOutlet weak var surnameField:    UITextField!
    @IBOutlet weak var firstNameField:  UITextField!

    // UI Table
    @IBOutlet weak var birthDatePickerCell: UITableViewCell!

    // UI Prescription Section
    @IBOutlet weak var rxPicker:                RxPickerController!
    @IBOutlet weak var rightRxPickerControl:    UIPickerView!

    // Constraints
    @IBOutlet var labelConstraints: [NSLayoutConstraint]!

    // Class
    var datePickerIsShown : Bool = false

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // We don't want to see the picker for the patient's date of birth if the cell view is collapsed.
        self.birthDatePickerCell.clipsToBounds = true
    }

    override func viewDidLayoutSubviews() {

        var offset : CGFloat = 0
        var pickerSection = 0

        for foo in labelConstraints {

            let rowSize = rightRxPickerControl.rowSizeForComponent(pickerSection)

            labelConstraints[pickerSection].constant = offset + rowSize.width * 0.5

            offset += rowSize.width
            pickerSection++
        }

    }

    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)

        // Dispose of the keyboard
        view.endEditing(true)
    }

    // MARK: UITableViewDelegate conformance

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if (indexPath.section == 0 && indexPath.row == 2 && !datePickerIsShown) { return 0.0 }

        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if (indexPath.section == 0 && indexPath.row == 1) {

            datePickerIsShown ^= true

            tableView.reloadData()
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
