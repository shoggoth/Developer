//
//  AdjustmentViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 04/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class AdjustmentListViewController : DynamicTableViewController {

    // MARK: Properties

    @IBOutlet weak var initialPriceLabel: UILabel!
    @IBOutlet weak var adjustmentLabel: UILabel!
    @IBOutlet weak var adjustedPriceLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Activate editing by giving the name of the edit segue.
        editSegueName = "editSegue"

        // Allow multiple selection
        canSelectMultipleRows = true

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "Adjustment", sortDescriptors: sortDescArray, cacheName: "AdjustmentCache")

        // Assign it an update block
        dataFetchController.cellUpdateBlock = { (cell: UITableViewCell?, object: AnyObject) in if let c = cell { return self.configureCell(c, withObject: object) } else { return nil }}
        dataFetchController.name = "Adjustment DFC"

        // Do the initial fetch
        dataFetchController.fetch()

        // Mark the initial adjustments
        if let adjustments = order.adjustments where adjustments.count != 0 { checkObjects(Array(adjustments))}

        // Magic to make us able to adjust table row heights without everything breaking.
        self.tableView.estimatedRowHeight = 44

        // Specify the select and deselect operations
        let displayBlock = {

            let order = self.order

            let rp = order.rawPrice
            let tp = order.totalPrice
            let ap = tp - rp

            self.initialPriceLabel.text = NSNumberFormatter.localizedStringFromNumber(rp, numberStyle: .CurrencyStyle)
            self.adjustmentLabel.text = NSNumberFormatter.localizedStringFromNumber(ap, numberStyle: .CurrencyStyle)
            self.adjustedPriceLabel.text = NSNumberFormatter.localizedStringFromNumber(tp, numberStyle: .CurrencyStyle)

            self.tableView.tableHeaderView?.backgroundColor = tp < 0 ? UIColor.redColor() : self.tableView.backgroundColor
        }

        cellSelectBlock = { (cell: UITableViewCell) in if let adjustment = self.objectForCell(cell) as? Adjustment { self.order.addAdjustmentsObject(adjustment); displayBlock() } }
        cellDeselectBlock = { (cell: UITableViewCell) in if let adjustment = self.objectForCell(cell) as? Adjustment { self.order.removeAdjustmentsObject(adjustment); displayBlock() } }

        if let headerView = tableView.tableHeaderView {

            headerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: headerView, attribute: .Top, relatedBy: .Equal, toItem: tableView, attribute: .Top, multiplier: 1.0, constant: 0).active = true
            NSLayoutConstraint(item: headerView, attribute: .Width, relatedBy: .Equal, toItem: tableView, attribute: .Width, multiplier: 1.0, constant: 0).active = true
            NSLayoutConstraint(item: headerView, attribute: .CenterX, relatedBy: .Equal, toItem: tableView, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true

            headerView.layoutIfNeeded()
        }

        displayBlock()
    }

    // MARK: Cell config.

    override func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        guard let adjustment = object as? Adjustment, adjCell = cell as? AdjustmentCell else { return cell }

        adjCell.nameLabel.text = adjustment.name
        adjCell.constantLabel.text = order.currencySymbol + (adjustment.constant?.stringValue ?? "0")
        adjCell.multiplierLabel.text = (adjustment.multiplier?.stringValue ?? "100") + "%"
        adjCell.typeLabel.text = adjustment.typeString()

        return adjCell
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // Going to the lens detail view controller for a new or edit operation?
        if let detailViewController = segue.destinationViewController as? AdjustmentDetailViewController {

            let dataStore = IDDispensingDataStore.defaultDataStore()

            // Is this an edit operation? Check the name of the segue to find out.
            if segue.identifier == editSegueName {

                // Get the lens involved from the segue sender
                if let adjustment = sender as? Adjustment {

                    detailViewController.loadBlock = {

                        detailViewController.navigationItem.title = "Edit Adjustment"

                        detailViewController.nameField.text = adjustment.name

                        detailViewController.nameField.text = adjustment.name
                        detailViewController.multiplierField.text = adjustment.multiplier?.stringValue
                        detailViewController.constantField.decimalNumber = adjustment.constant ?? NSDecimalNumber.zero()
                        detailViewController.adjustmentTypeSegControl.selectedSegmentIndex = adjustment.type?.integerValue ?? 0
                    }

                    detailViewController.editBlock = {

                        // Get values from the detail viewcontroller
                        adjustment.name = detailViewController.nameField.text
                        adjustment.multiplier = detailViewController.multiplierField.decimalNumber
                        adjustment.constant = detailViewController.constantField.decimalNumber
                        adjustment.type = detailViewController.adjustmentTypeSegControl.selectedSegmentIndex

                        // Save edits and reload the table
                        dataStore.save()
                        self.tableView.reloadData()
                    }
                }

            } else {

                // If it isn't an edit operation then it must be a new object operation
                detailViewController.saveBlock = {

                    dataStore.addAdjustmentWithName(detailViewController.nameField.text,
                        multiplier: detailViewController.multiplierField.decimalNumber,
                        constant: detailViewController.constantField.decimalNumber,
                        adjustmentType: detailViewController.adjustmentTypeSegControl.selectedSegmentIndex)

                    dataStore.save()
                    
                    // After a new lens is added and saved, reload the table data so that we can get the correct check mark.
                    self.tableView.reloadData()
                }
            }
        }
    }
}

//
// MARK: - Adjustment cell
//
// Has not yet been documented.
//

class AdjustmentCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var constantLabel: UILabel!
    @IBOutlet weak var multiplierLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
}

//
// MARK: - Adjustment Detail VC
//
// Has not yet been documented.
//

class AdjustmentDetailViewController: StaticTableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var constantField: UITextField!
    @IBOutlet weak var multiplierField: UITextField!
    @IBOutlet weak var adjustmentTypeSegControl: UISegmentedControl!
}
