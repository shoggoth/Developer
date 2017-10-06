//
//  FrameStyleViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Frame Colour Master TVC
//
// Has not yet been documented.
//

class FrameStyleTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Rather than deleting the frame style object, we want to remove the style from the list of appropriate
        // frame styles for the selected frame if the user deletes.
        objectDeleteBlock = { (object: AnyObject?) in

            if let frameOrder = self.order.frameOrder, fStyle = object as? FrameStyle {

                // Remove this style from the list of styles available to the frame
                frameOrder.frame.removeAvailableStylesObject(fStyle)

                // Has someone deleted the style that belonged to this order?
                if let orderedStyle = frameOrder.frameStyle {

                    if orderedStyle == fStyle { frameOrder.frameStyle = nil }
                }
            }
        }

        cellSelectBlock = { (cell: UITableViewCell) in self.order.frameOrder.frameStyle = self.objectForCell(cell) as! FrameStyle }
        cellDeselectBlock = { (cell: UITableViewCell) in self.order.frameOrder.frameStyle = nil }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "styleCode", ascending: true), NSSortDescriptor(key: "colour", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "FrameStyle", sortDescriptors: sortDescArray, sectionNameKeyPath: nil)
        dataFetchController.predicate = NSPredicate(format: "frames contains %@", order.frameOrder.frame)

        // Do the initial fetch
        dataFetchController.fetch()
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Check the selected
        if let frameStyle = order.frameOrder.frameStyle {

            checkedPath = indexPathForObject(frameStyle)

            if checkedPath != nil { tableView.scrollToRowAtIndexPath(checkedPath!, atScrollPosition: .Middle, animated: true) }
        }
    }

    // MARK: Cell config.

    override func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let frameStyle = object as! FrameStyle
        let frameStyleCell = cell as! FrameStyleCell

        frameStyleCell.styleLabel.text = "\(frameStyle.styleCode)"
        frameStyleCell.colourLabel.text = "\(frameStyle.colour)"

        return frameStyleCell
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // After a new frame is added and saved, reload the table data so that we can get the correct check mark.
        if let dvc = segue.destinationViewController as? FrameStyleDetailViewController {

            dvc.saveBlock = { self.tableView.reloadData() }
        }
    }
}

//
// MARK: - Frame Colour cell
//
// Has not yet been documented.
//

class FrameStyleCell : UITableViewCell {

    // UI

    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet weak var styleLabel: UILabel!
}

//
// MARK: - Frame Colour Detail VC
//
// Has not yet been documented.
//

class FrameStyleDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var frameColourField: UITextField!
    @IBOutlet weak var frameStyleField: UITextField!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Add save functionality to the existing save block.
        let oldSaveBlock = self.saveBlock

        self.saveBlock = {

            // Saving so let's create a new frame
            if let frameOrder = self.order.frameOrder {

                frameOrder.frameStyle = self.dataStore.addFrameStyleWithStyle(self.frameStyleField.text, colour: self.frameColourField.text, toFrame: frameOrder.frame)

                self.dataStore.save()

                oldSaveBlock?()
            }
        }
    }
}
