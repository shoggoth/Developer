//
//  OrderStatusViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Order Status Master TVC
//
// Has not yet been documented.
//

class OrderStatusMasterTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Activate editing by giving the name of the edit segue.
        editSegueName = "editSegue"

        cellSelectBlock = { (cell: UITableViewCell) in if let status = self.objectForCell(cell) as? OrderStatus { self.order.status = status } }
        cellDeselectBlock = { (cell: UITableViewCell) in self.order.status = nil }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "OrderStatus", sortDescriptors: sortDescArray, sectionNameKeyPath: nil)

        // Do the initial fetch
        dataFetchController.fetch()
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Check the selected
        if let status = order.status {

            checkedPath = indexPathForObject(status)

            if checkedPath != nil { tableView.scrollToRowAtIndexPath(checkedPath!, atScrollPosition: .Middle, animated: true) }
        }
    }

    // MARK: Cell config.

    override func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let status = object as! OrderStatus
        let statusCell = cell as! OrderStatusCell

        statusCell.nameLabel.text = status.name

        return statusCell
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // Going to the frame detail view controller for a new or edit operation?
        if let detailViewController = segue.destinationViewController as? OrderStatusDetailViewController {

            // Is this an edit operation? Check the name of the segue to find out.
            if segue.identifier == editSegueName {

                // Get the frame involved from the segue sender
                if let status = sender as? OrderStatus {

                    detailViewController.loadBlock = {

                        detailViewController.navigationItem.title = "Edit Order Status"
                        detailViewController.nameField.text = status.name
                    }

                    detailViewController.editBlock = {

                        // Get values from the detail viewcontroller
                        status.name = detailViewController.nameField.text

                        self.tableView.reloadData()
                    }
                }

            } else {

                // If it isn't an edit operation then it must be a new object operation
                if let frameOrder = self.order.frameOrder {

                    let dataStore = IDDispensingDataStore.defaultDataStore()

                    detailViewController.saveBlock = {

                        // Get values from the detail viewcontroller
                        let statusName = detailViewController.nameField.text

                        // Saving so let's create a new order status
                        self.order.status = dataStore.addEntityNamed("OrderStatus") as! OrderStatus
                        self.order.status.name = statusName

                        dataStore.save()

                        // After a new lens is added and saved, reload the table data so that we can get the correct check mark.
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

//
// MARK: - Order Status cell
//
// Has not yet been documented.
//

class OrderStatusCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
}

//
// MARK: - Order Status Detail VC
//
// Has not yet been documented.
//

class OrderStatusDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var nameField: UITextField!

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // If we are segueing to another Order TVC from this one, pass on the order.
//        if let dvc = segue.destinationViewController as? OrderStatusManufacturerTableViewController {
//
//            dvc.cellSelectBlock = { (cell: UITableViewCell) in
//
//                self.manufacturerLabel.text = dvc.objectForCell(cell)?.name
//            }
//        }
    }
}
