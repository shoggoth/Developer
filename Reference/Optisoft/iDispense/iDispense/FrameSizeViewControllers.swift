//
//  FrameSizeViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Frame Size Master TVC
//
// Has not yet been documented.
//

class FrameSizeTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Rather than deleting the frame size object, we want to remove the size from the list of appropriate
        // frame sizes for the selected frame if the user deletes.
        objectDeleteBlock = { (object: AnyObject?) in

            if let frameOrder = self.order.frameOrder, fSize = object as? FrameSize {

                // Remove this size from the list of sizes available to the frame
                frameOrder.frame.removeAvailableSizesObject(fSize)

                // Has someone deleted the size that belonged to this order?
                if let orderedSize = frameOrder.frameSize {

                    if orderedSize == fSize { frameOrder.frameSize = nil }
                }
            }
        }

        cellSelectBlock = { (cell: UITableViewCell) in self.order.frameOrder.frameSize = self.objectForCell(cell) as! FrameSize }
        cellDeselectBlock = { (cell: UITableViewCell) in self.order.frameOrder.frameSize = nil }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "sizeMeasure", ascending: true), NSSortDescriptor(key: "lengthMeasure", ascending: true), NSSortDescriptor(key: "bridgeMeasure", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "FrameSize", sortDescriptors: sortDescArray, sectionNameKeyPath: nil)
        dataFetchController.predicate = NSPredicate(format: "frames contains %@", order.frameOrder.frame)

        // Do the initial fetch
        dataFetchController.fetch()
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Check the selected
        if let frameSize = order.frameOrder.frameSize {

            checkedPath = indexPathForObject(frameSize)

            if checkedPath != nil { tableView.scrollToRowAtIndexPath(checkedPath!, atScrollPosition: .Middle, animated: true) }
        }
    }

    // MARK: Cell config.

    override func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let frameSize = object as! FrameSize
        let frameSizeCell = cell as! FrameSizeCell

        frameSizeCell.sizeLabel.text = "\(frameSize.sizeMeasure)"
        frameSizeCell.lengthLabel.text = "\(frameSize.lengthMeasure)"
        frameSizeCell.bridgeLabel.text = "\(frameSize.bridgeMeasure)"

        return frameSizeCell
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // After a new frame is added and saved, reload the table data so that we can get the correct check mark.
        if let dvc = segue.destinationViewController as? FrameSizeDetailViewController {

            dvc.saveBlock = { self.tableView.reloadData() }
        }
    }
}

//
// MARK: - Frame Size cell
//
// Has not yet been documented.
//

class FrameSizeCell : UITableViewCell {

    // UI

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var bridgeLabel: UILabel!
}

//
// MARK: - Frame Size Detail VC
//
// Has not yet been documented.
//

class FrameSizeDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var frameSizeField: UITextField!
    @IBOutlet weak var frameBridgeField: UITextField!
    @IBOutlet weak var frameLengthField: UITextField!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Add save functionality to the existing save block.
        let oldSaveBlock = self.saveBlock

        self.saveBlock = {

            // Saving so let's create a new frame
            if let frameOrder = self.order.frameOrder {

                frameOrder.frameSize = self.dataStore.addFrameSizeWithSize((self.frameSizeField.text as NSString).floatValue, length: (self.frameLengthField.text as NSString).floatValue, bridge: (self.frameBridgeField.text as NSString).floatValue, toFrame: frameOrder.frame)

                self.dataStore.save()

                oldSaveBlock?()
            }
        }
    }
}
