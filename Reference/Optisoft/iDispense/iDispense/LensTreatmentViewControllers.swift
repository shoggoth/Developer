//
//  LensTreatmentViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 27/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Lens Treatment TVC
//
// Has not yet been documented.
//

class LensTreatmentTableViewController : DynamicTableViewController, LensAdditions {

    // MARK: Properties

    var isLeftLens: Bool = false
    var subType: LensTreatmentType = .None

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Activate editing by giving the name of the edit segue.
        editSegueName = "editSegue"

        // Set the navigation title
        navigationItem.title = "Select \(subType.rawValue)"

        // Specify the select and deselect operations
        cellSelectBlock = { [weak self] (cell: UITableViewCell) in

            if let s = self {

                s.dataStore.perform({ (ds: CDSDataStore) in

                    if let treatment = s.objectForCell(cell) as? LensTreatment, let lensOrder = s.order.lensOrder {

                        // First, check if the treatment is in the order
                        if let removeTreatment = lensOrder.treatment(s.subType, onLeft: s.isLeftLens) {

                            // If it is, remove it.
                            if s.isLeftLens { lensOrder.removeLeftTreatmentsObject(removeTreatment) } else { lensOrder.removeRightTreatmentsObject(removeTreatment) }
                        }

                        if let lensOrder = s.order.lensOrder {

                            if s.isLeftLens { lensOrder.addLeftTreatmentsObject(treatment) } else { lensOrder.addRightTreatmentsObject(treatment) }
                        }
                    }
                    
                    return nil
                    
                    }, withCompletion:nil)
            }
        }
        
        cellDeselectBlock = { [weak self] (cell: UITableViewCell) in

            if let s = self {

                s.dataStore.perform({ (ds: CDSDataStore) in

                    if let treatment = s.objectForCell(cell) as? LensTreatment, let lensOrder = s.order.lensOrder {

                        // Deselecting the treatment just removes it from the current order.
                        if s.isLeftLens { lensOrder.removeLeftTreatmentsObject(treatment) } else { lensOrder.removeRightTreatmentsObject(treatment) }
                    }

                    return nil
                    
                    }, withCompletion:nil)
            }
        }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "LensTreatment", sortDescriptors: sortDescArray, mocToObserve: dataStore.managedObjectContext)

        // Assign it an update block
        dataFetchController.cellUpdateBlock = { [weak self] (cell: UITableViewCell?, object: AnyObject) in if let c = cell { return self?.configureCell(c, withObject: object) } else { return nil }}
        dataFetchController.name = "Lens Treatment DFC"

        // Define the predicates for the search. The manufacturer of the treatment should match the lens'.
        if let lens = isLeftLens ? self.order.lensOrder?.leftLens : self.order.lensOrder?.rightLens {

            dataFetchController.predicate = NSPredicate(format: "type = %@ and manufacturer = %@ and hidden = NO", subType.rawValue, lens.manufacturer ?? "None")

        } else {

            dataFetchController.predicate = NSPredicate(format: "type = %@ and hidden = NO", subType.rawValue)
        }

        // Fetch and reload Data.
        dataFetchController.fetchWithCompletion(nil)

        // Treatments have a special delete function so that existing orders can keep the correct price.
        objectDeleteBlock = { [weak self] (object: AnyObject?) in guard let s = self else { return }

            if let treatment = object as? LensTreatment {

                s.dataStore.perform({ (ds: CDSDataStore) in

                    // Mark the lens as hidden
                    treatment.hidden = true

                    // See if it's referenced by the current lens order and remove references if so.
                    if let lo = s.order.lensOrder {

                        if let rt = lo.rightTreatments, rt.contains(treatment) { lo.removeRightTreatmentsObject(treatment) }
                        if let lt = lo.leftTreatments, lt.contains(treatment) { lo.removeLeftTreatmentsObject(treatment) }
                    }

                    return ds
                    
                    }, withCompletion: nil)
            }
        }
    }

    // MARK: Cell config.

    func treatmentIsChecked(_ treatment: LensTreatment) -> Bool {

        return self.isLeftLens ? self.order.lensOrder?.leftTreatments?.contains(treatment) ?? false : self.order.lensOrder?.rightTreatments?.contains(treatment) ?? false
    }

    override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        guard let treatment = object as? LensTreatment, let treatmentCell = cell as? LensTreatmentCell else { return cell }

        var tn: String?
        var tp: String = ""
        var checked: Bool = false

        self.dataStore.perform({ (ds: CDSDataStore) in

            tn = treatment.name
            tp = treatment.priceString

            checked = self.treatmentIsChecked(treatment)

            return nil

        }, withCompletion:{ _ in

            treatmentCell.nameLabel.text = tn
            treatmentCell.priceLabel.text = tp

            if checked { cell.accessoryType = .checkmark } else { cell.accessoryType = .none }
        })

        return treatmentCell
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        // Going to the lens detail view controller for a new or edit operation?
        if let detailViewController = segue.destination as? LensTreatmentDetailViewController {

            // Is this an edit operation? Check the name of the segue to find out.
            if segue.identifier == editSegueName {

                // Get the lens involved from the segue sender
                if let treatment = sender as? LensTreatment {

                    detailViewController.loadBlock = { [weak self] (stvc: StaticTableViewController) in guard let s = self, let vc = stvc as? LensTreatmentDetailViewController else { return }

                        vc.navigationItem.title = "Edit \(s.subType.rawValue)"

                        var tn: String?
                        var tp: NSDecimalNumber = NSDecimalNumber.zero

                        vc.dataStore.perform({ (ds: CDSDataStore) in

                            tn = treatment.name
                            tp = treatment.price ?? NSDecimalNumber.zero

                            return nil

                        }, withCompletion:{ _ in

                            vc.nameField.text = tn
                            vc.priceField.decimalNumber = tp
                        })
                    }

                    detailViewController.editBlock = { (stvc: StaticTableViewController) in guard let vc = stvc as? LensTreatmentDetailViewController else  { return }

                        let tn = vc.nameField.text
                        let tp = vc.priceField.decimalNumber

                        vc.dataStore.perform({ (ds: CDSDataStore) in

                            let treatmentDataAltered = tn != treatment.name || tp != treatment.price;

                            if treatmentDataAltered {

                                // Hide the old treatment
                                treatment.hidden = true

                                // Create a new treatment with the edits
                                if let newTreatment = vc.dataStore.addLensTreatment(withName: tn!, price: tp, type: treatment.type!, manuName: treatment.manufacturer!.name!) {

                                    // Replace with the new lens in the order
                                    if let lo = vc.order.lensOrder {

                                        if let rt = lo.rightTreatments, rt.contains(treatment) {

                                            lo.removeRightTreatmentsObject(treatment)
                                            lo.addRightTreatmentsObject(newTreatment)
                                        }

                                        if let lt = lo.leftTreatments, lt.contains(treatment) {

                                            lo.removeLeftTreatmentsObject(treatment)
                                            lo.addLeftTreatmentsObject(newTreatment)
                                        }
                                    }

                                    let modDate = Date()

                                    newTreatment.dateModified = modDate
                                    vc.order.dateModified = modDate
                                }
                            }

                            return nil

                        }, withCompletion:nil)
                    }
                }

            } else {

                // If it isn't an edit operation then it must be a new object operation
                detailViewController.navigationItem.title = "New \(subType.rawValue)"

                // We need the lens so that the treatment can be matched up with the lens manufacturer
                if let lensOrder = self.order.lensOrder, let lens = self.isLeftLens ? lensOrder.leftLens : lensOrder.rightLens {

                    let treatSetOperation = self.isLeftLens ? { (treat: LensTreatment) in lensOrder.addLeftTreatmentsObject(treat) } : { (treat: LensTreatment) in lensOrder.addRightTreatmentsObject(treat) }
                    let treatRemoveOperation = self.isLeftLens ? { (treat: LensTreatment) in lensOrder.removeLeftTreatmentsObject(treat) } : { (treat: LensTreatment) in lensOrder.removeRightTreatmentsObject(treat) }

                    detailViewController.saveBlock = { [weak self] (stvc: StaticTableViewController) in guard let s = self, let vc = stvc as? LensTreatmentDetailViewController else { return }

                        // Get values from the detail viewcontroller
                        if let treatName = vc.nameField.text {

                            let treatPrice = vc.priceField.decimalNumber

                            vc.dataStore.perform({ (ds: CDSDataStore) in

                                // If the order already has a treatment of this type, remove it
                                if let treatment = lensOrder.treatment(s.subType, onLeft: s.isLeftLens) { treatRemoveOperation(treatment) }

                                // Create the new treatment and add it to the order
                                if let newTreatment = vc.dataStore.addLensTreatment(withName: treatName, price:treatPrice, type: s.subType.rawValue, manuName: lens.manufacturer?.name ?? "") {

                                    // Table completion block will scroll to the correct row
                                    s.dataFetchController.tableUpdateCompletionBlock = { (tv: UITableView) in

                                        if let ip = s.indexPathForObject(newTreatment) { tv.scrollToRow(at: ip, at: .middle, animated: true) }

                                        // This will be a one-shot operation
                                        return true
                                    }

                                    // Set the treatment and order modification date.
                                    treatSetOperation(newTreatment)
                                    vc.order.dateModified = Date()
                                }
                                
                                return nil
                                
                                }, withCompletion:nil)
                        }
                    }
                }
            }
        }
    }
}

//
// MARK: - Lens Treatment cell
//
// Has not yet been documented.
//

class LensTreatmentCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}

//
// MARK: - Lens Treatment Detail VC
//
// Has not yet been documented.
//

class LensTreatmentDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!
}
