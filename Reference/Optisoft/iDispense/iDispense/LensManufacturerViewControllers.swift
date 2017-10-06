//
//  LensManufacturerViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 27/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Lens Manufacturer TVC
//
// Has not yet been documented.
//

class LensManufacturerTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "LensManufacturer", sortDescriptors: sortDescArray, mocToObserve: dataStore.managedObjectContext)

        // Assign it an update block
        dataFetchController.cellUpdateBlock = { [weak self] (cell: UITableViewCell?, object: AnyObject) in if let c = cell { return self?.configureCell(c, withObject: object) } else { return nil }}
        dataFetchController.name = "Lens Manufacturer DFC"

        // Fetch and reload Data.
        dataFetchController.fetchWithCompletion(nil)
    }

    // MARK: Cell config.

    override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        guard let manufacturer = object as? LensManufacturer, let manufacturerCell = cell as? LensManufacturerCell else { return cell }

        dataStore.perform({ (ds: CDSDataStore) in return manufacturer.name }, withCompletion: { (mn: Any?) in manufacturerCell.nameLabel.text = mn as? String })

        return manufacturerCell
    }

    // MARK: Table Edit

    override func tableView(_ view: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        // Don't allow these to be edited or there will be lenses that're orphaned
        let canEdit = ((objectForIndexPath(indexPath) as? LensManufacturer)?.lenses?.count == 0)

        return canEdit
    }
}

//
// MARK: - Lens Manufacturer cell
//
// Has not yet been documented.
//

class LensManufacturerCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
}

//
// MARK: - Lens Manufacturer Detail VC
//
// Has not yet been documented.
//

class LensManufacturerDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var lensManufacturerField: UITextField!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        self.saveBlock = { (stvc: StaticTableViewController) in guard let vc = stvc as? LensManufacturerDetailViewController else { return }

            // Create the new lens manufacturer
            vc.dataStore.perform({ (ds: CDSDataStore) in

                if let mn = vc.lensManufacturerField.text {

                    vc.dataStore.addLensManufacturerNamed(mn)

                    return mn
                }

                return nil

                }, withCompletion: nil)
        }
    }
}
