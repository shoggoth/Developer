//
//  FrameMasterTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 27/01/2015.
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

        // If you want to change this controller so that there is no editing allowed, do it here.
        canEditRows = true

        super.viewDidLoad()

        cellSelectBlock = { (cell: UITableViewCell) in self.order.frameOrder.frame = self.objectForCell(cell) as Frame }
        cellDeselectBlock = { (cell: UITableViewCell) in self.order.frameOrder.frame = nil }

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

        let frame = object as Frame
        let frameCell = cell as FrameCell

        frameCell.nameLabel.text = frame.name
        frameCell.frameTypeLabel.text = frame.typeString()
        frameCell.framePriceLabel.text = frame.priceString()

        return frameCell
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // After a new frame is added and saved, reload the table data so that we can get the correct check mark.
        if let dvc = segue.destinationViewController as? FrameDetailViewController {

            dvc.saveBlock = { self.tableView.reloadData() }
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

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
}

//
// MARK: - Frame Manufacturer TVC
//
// Has not yet been documented.
//

class FrameManufacturerTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "FrameManufacturer", sortDescriptors: sortDescArray, sectionNameKeyPath: nil)

        // Do the initial fetch
        dataFetchController.fetch()
    }

    // MARK: Cell config.

    override func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let manufacturer = object as FrameManufacturer
        let manufacturerCell = cell as FrameManufacturerCell

        manufacturerCell.nameLabel.text = manufacturer.name

        return manufacturerCell
    }
}

//
// MARK: - Frame Manufacturer cell
//
// Has not yet been documented.
//

class FrameManufacturerCell : UITableViewCell {

    // UI
    @IBOutlet weak var nameLabel: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
}

