//
//  FrameDetailViewController.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Frame Detail VC
//
// Has not yet been documented.
//

class FrameDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var frameManufacturerLabel: UILabel!
    @IBOutlet weak var frameNameField: UITextField!
    @IBOutlet weak var framePriceField: UITextField!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Add save functionality to the existing save block.
        let oldSaveBlock = self.saveBlock

        self.saveBlock = {

            // Saving so let's create a new frame
            if let frameOrder = self.order.frameOrder {

                frameOrder.frame = self.dataStore.addFrameWithName(self.frameNameField.text, manuName: self.frameManufacturerLabel.text, price: (self.framePriceField.text as NSString).floatValue, frameType: 0)
                self.dataStore.save()

                oldSaveBlock?()
            }
        }
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        super.prepareForSegue(segue, sender: sender)

        // If we are segueing to another Order TVC from this one, pass on the order.
        if let dvc = segue.destinationViewController as? FrameManufacturerTableViewController {

            dvc.cellSelectBlock = { (cell: UITableViewCell) in

                self.frameManufacturerLabel.text = dvc.objectForCell(cell)?.name
            }
        }
    }
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
