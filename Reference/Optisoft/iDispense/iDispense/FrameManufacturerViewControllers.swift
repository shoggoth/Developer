//
//  FrameManufacturerViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 27/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

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

        let manufacturer = object as! FrameManufacturer
        let manufacturerCell = cell as! FrameManufacturerCell

        manufacturerCell.nameLabel.text = manufacturer.name

        return manufacturerCell
    }

    // MARK: Table Edit

    override func tableView(view: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        // Don't allow these to be edited or there will be lenses that're orphaned
        let canEdit = (objectForIndexPath(indexPath) as? FrameManufacturer)?.frames.count == 0

        return canEdit
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
}

//
// MARK: - Frame Manufacturer Detail VC
//
// Has not yet been documented.
//

class FrameManufacturerDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var frameManufacturerField: UITextField!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        self.saveBlock = {

            // Create the new frame manufacturer
            let newManufacturer = self.dataStore.addFrameManufacturerNamed(self.frameManufacturerField.text)
        }
    }
}
