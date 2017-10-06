//
//  LensViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - LensAdditions
//
// Has not yet been documented.
//

protocol LensAdditions {

    var isLeftLens: Bool { set get }
    var subType: LensTreatmentType { set get }
}

//
// MARK: - Lens Master TVC
//
// Has not yet been documented.
//

class LensMasterTableViewController : DynamicTableViewController, LensAdditions {

    // MARK: Properties

    var isLeftLens: Bool = false
    var subType: LensTreatmentType = .None

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Activate editing by giving the name of the edit segue.
        editSegueName = "editSegue"

        // Specify the select and deselect operations
        if let lensOrder = order.lensOrder {

            let sideSet = self.isLeftLens ? { (lens: Lens?) in lensOrder.leftLens = lens } : { (lens: Lens?) in lensOrder.rightLens = lens }
            let lensSetOperation = { [weak self] (lens: Lens?) in self?.dataStore.perform({ (ds: CDSDataStore) in sideSet(lens); return nil }, withCompletion:nil)}

            cellSelectBlock = { [weak self] (cell: UITableViewCell) in if let lens = self?.objectForCell(cell) as? Lens { lensSetOperation(lens); self?.order.dateModified = Date() }}
            cellDeselectBlock = { [weak self] (cell: UITableViewCell) in lensSetOperation(nil); self?.order.dateModified = Date() }
        }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "manufacturer.name", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "Lens", sortDescriptors: sortDescArray, mocToObserve: dataStore.managedObjectContext)
        dataFetchController.predicate = NSPredicate(format: "hidden = NO")

        // Assign it an update block
        dataFetchController.cellUpdateBlock = { [weak self] (cell: UITableViewCell?, object: AnyObject) in if let c = cell { return self?.configureCell(c, withObject: object) } else { return nil }}
        dataFetchController.name = ">> Lens Master DFC \(arc4random())"

        // Fetch and reload Data.
        dataFetchController.fetchWithCompletion(nil)

        // Lens have a special delete function so that existing orders can keep the correct price.
        objectDeleteBlock = { [weak self] (object: AnyObject?) in guard let s = self else { return }

            if let lens = object as? Lens {

                s.dataStore.perform({ (ds: CDSDataStore) in

                    // Mark the lens as hidden
                    lens.hidden = true

                    // See if it's referenced by the current lens order and remove references if so.
                    if s.order.lensOrder?.right == lens { s.order.lensOrder?.right = nil }
                    if s.order.lensOrder?.left == lens { s.order.lensOrder?.left = nil }

                    // If there are no references left to the lens, it should be safe to delete.
                    if lens.leftOrders?.isEmpty ?? true && lens.rightOrders?.isEmpty ?? true { s.dataStore.managedObjectContext.delete(lens) }

                    return ds
                    
                }, withCompletion: nil)
            }
        }
    }
    
    // MARK: Cell config.

    func lensIsChecked(_ lens: Lens) -> Bool {

        guard let lensOrder = self.order.lensOrder else { return false }

        return self.isLeftLens ? lensOrder.leftLens == lens : lensOrder.rightLens == lens
    }

    override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        guard let lens = object as? Lens, let lensCell = cell as? LensCell else { return cell }

        var ln: String?
        var lt: String?
        var lp: String?
        var checked: Bool = false

        self.dataStore.perform({ (ds: CDSDataStore) in

            ln = lens.nameString
            lt = lens.typeString()
            lp = lens.priceString

            checked = self.lensIsChecked(lens)

            return nil

            }, withCompletion:{ _ in

                lensCell.nameLabel.text = ln
                lensCell.lensTypeLabel.text = lt
                lensCell.lensPriceLabel.text = lp

                if checked { cell.accessoryType = .checkmark } else { cell.accessoryType = .none }
        })

        return lensCell
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        // Going to the lens detail view controller for a new or edit operation?
        if let detailViewController = segue.destination as? LensDetailViewController {

            // Is this an edit operation? Check the name of the segue to find out.
            if segue.identifier == editSegueName {

                // Get the lens involved from the segue sender
                if let lens = sender as? Lens {

                    detailViewController.loadBlock = { (stvc: StaticTableViewController) in guard let vc = stvc as? LensDetailViewController else { return }

                        vc.navigationItem.title = "Edit Lens"

                        var ln: String?
                        var lm: String?
                        var lp: NSDecimalNumber = NSDecimalNumber.zero

                        vc.dataStore.perform({ (ds: CDSDataStore) in

                            ln = lens.name
                            lm = lens.manufacturer?.name
                            lp = lens.price ?? NSDecimalNumber.zero

                            return nil
                            
                            }, withCompletion:{ _ in

                                vc.nameField.text = ln
                                vc.manufacturerLabel.text = lm
                                vc.priceField.decimalNumber = lp
                        })
                    }

                    detailViewController.editBlock = { (stvc: StaticTableViewController) in guard let vc = stvc as? LensDetailViewController else { return }

                        let ln = vc.nameField.text
                        let lp = vc.priceField.decimalNumber
                        let mn = vc.manufacturerLabel.text

                        vc.dataStore.perform({ (ds: CDSDataStore) in

                            let lensDataAltered = ln != lens.name || mn != lens.manufacturer?.name || lp != lens.price

                            if lensDataAltered {

                                // Hide the old lens
                                lens.hidden = true

                                // Create a new lens with the edits
                                let newLens = vc.dataStore.addLens(withName: ln!, manuName: mn!, price: lp, material: nil, visType: nil)

                                // Replace with the new lens in the order
                                if let lensOrder = vc.order.lensOrder {

                                    if lens == lensOrder.right { lensOrder.right = newLens }
                                    if lens == lensOrder.left { lensOrder.left = newLens }
                                }

                                vc.order.dateModified = Date()
                            }

                            return nil
                            
                        }, withCompletion: nil)
                    }
                }

            } else {

                // If it isn't an edit operation then it must be a new object operation
                if let lensOrder = self.order.lensOrder {

                    let lensSetOperation = self.isLeftLens ? { (lens: Lens) in lensOrder.leftLens = lens } : { (lens: Lens) in lensOrder.rightLens = lens }

                    detailViewController.saveBlock = { [weak self] (stvc: StaticTableViewController) in guard let s = self, let vc = stvc as? LensDetailViewController else { return }

                        // Get values from the detail viewcontroller
                        if let lensName = vc.nameField.text, let manuName = vc.manufacturerLabel.text {

                            let lensPrice = vc.priceField.decimalNumber

                            vc.dataStore.perform({ (ds: CDSDataStore) in

                                // Saving so let's create a new lens
                                if let newLens = vc.dataStore.addLens(withName: lensName, manuName: manuName, price: lensPrice, material: nil, visType: nil) {

                                    // Table completion block will scroll to the correct row
                                    s.dataFetchController.tableUpdateCompletionBlock = { (tv: UITableView) in

                                        if let ip = s.indexPathForObject(newLens) { tv.scrollToRow(at: ip, at: .middle, animated: true) }

                                        // This will be a one-shot operation
                                        return true
                                    }

                                    // Set the lens and order modification date.
                                    lensSetOperation(newLens)
                                    vc.order.dateModified = Date()
                                }
                                
                                return nil
                                
                            }, withCompletion: nil)
                        }
                    }
                }
            }
        }
    }
}

//
// MARK: - Lens cell
//
// Has not yet been documented.
//

class LensCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lensTypeLabel: UILabel!
    @IBOutlet weak var lensPriceLabel: UILabel!
}

//
// MARK: - Lens Detail VC
//
// Has not yet been documented.
//

class LensDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        // If we are segueing to another Order TVC from this one, pass on the order.
        if let manufacturerViewController = segue.destination as? LensManufacturerTableViewController {

            weak var mvc = manufacturerViewController

            // There is no cell deselect block so this will return as soon as a manufacturer has been selected.
            manufacturerViewController.cellSelectBlock = { [weak self] (cell: UITableViewCell) in
                
                self?.manufacturerLabel.text = mvc?.objectForCell(cell)?.name
            }
        }
    }
}
