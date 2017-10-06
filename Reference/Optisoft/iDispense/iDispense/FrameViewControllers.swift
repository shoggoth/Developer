//
//  FrameViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Frame Master TVC
//
// Has not yet been documented.
//

class FrameMasterTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Activate editing by giving the name of the edit segue.
        editSegueName = "editSegue"

        if let frameOrder = order.frameOrder {

            cellSelectBlock = { (cell: UITableViewCell) in

                frameOrder.frame = self.objectForCell(cell) as! Frame
                frameOrder.frameSize = nil
                frameOrder.frameStyle = nil
            }

            cellDeselectBlock = { (cell: UITableViewCell) in

                frameOrder.frame = nil
                frameOrder.frameSize = nil
                frameOrder.frameStyle = nil
            }
        }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "manufacturer.name", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "Frame", sortDescriptors: sortDescArray, sectionNameKeyPath: "manufacturer.name")

        // Do the initial fetch
        dataFetchController.fetch()
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Check the selected
        if let frame = order.frameOrder.frame {

            checkedPath = indexPathForObject(frame)

            if checkedPath != nil { tableView.scrollToRowAtIndexPath(checkedPath!, atScrollPosition: .Middle, animated: true) }
        }
    }

    // MARK: Cell config.

    override func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let frame = object as! Frame
        let frameCell = cell as! FrameCell

        frameCell.nameLabel.text = frame.name
        frameCell.frameTypeLabel.text = frame.typeString()
        frameCell.framePriceLabel.text = frame.priceString()

        return frameCell
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // Going to the frame detail view controller for a new or edit operation?
        if let detailViewController = segue.destinationViewController as? FrameDetailViewController {

            // Is this an edit operation? Check the name of the segue to find out.
            if segue.identifier == editSegueName {

                // Get the frame involved from the segue sender
                if let frame = sender as? Frame {

                    detailViewController.loadBlock = {

                        detailViewController.navigationItem.title = "Edit Frame"

                        detailViewController.manufacturerLabel.text = frame.manufacturer.name
                        detailViewController.nameField.text = frame.name
                        detailViewController.priceField.text = "\(frame.price)"
                        detailViewController.typeSegControl.selectedSegmentIndex = Int(frame.type)
                    }

                    detailViewController.editBlock = {

                        // Get values from the detail viewcontroller
                        frame.manufacturer = IDDispensingDataStore.defaultDataStore().addFrameManufacturerNamed(detailViewController.manufacturerLabel.text)
                        frame.name = detailViewController.nameField.text
                        frame.price = (detailViewController.priceField.text as NSString).floatValue
                        frame.type = Int16(detailViewController.typeSegControl.selectedSegmentIndex)

                        self.tableView.reloadData()
                    }
                }

            } else {

                // If it isn't an edit operation then it must be a new object operation
                if let frameOrder = self.order.frameOrder {

                    let dataStore = IDDispensingDataStore.defaultDataStore()

                    detailViewController.saveBlock = {

                        // Get values from the detail viewcontroller
                        let frameName = detailViewController.nameField.text
                        let manuName = detailViewController.manufacturerLabel.text
                        let framePrice = (detailViewController.priceField.text as NSString).floatValue

                        // Saving so let's create a new frame
                        frameOrder.frame = dataStore.addFrameWithName(frameName, manuName: manuName, price: framePrice, frameType: detailViewController.typeSegControl.selectedSegmentIndex)
                        dataStore.save()

                        // Clear details for the other frame that may have been selected.
                        frameOrder.frameSize = nil
                        frameOrder.frameStyle = nil

                        // After a new lens is added and saved, reload the table data so that we can get the correct check mark.
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

//
// MARK: - Frame cell
//
// Has not yet been documented.
//

class FrameCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var frameTypeLabel: UILabel!
    @IBOutlet weak var framePriceLabel: UILabel!
}

//
// MARK: - Frame Detail VC
//
// Has not yet been documented.
//

class FrameDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var typeSegControl: UISegmentedControl!

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // If we are segueing to another Order TVC from this one, pass on the order.
        if let dvc = segue.destinationViewController as? FrameManufacturerTableViewController {

            dvc.cellSelectBlock = { (cell: UITableViewCell) in

                self.manufacturerLabel.text = dvc.objectForCell(cell)?.name
            }
        }
    }
}
