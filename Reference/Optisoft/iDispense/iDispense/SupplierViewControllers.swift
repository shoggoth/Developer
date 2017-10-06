//
//  SupplierViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: - Supplier Master TVC
//
// Has not yet been documented.
//

class SupplierMasterTableViewController : DynamicTableViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Activate editing by giving the name of the edit segue.
        editSegueName = "editSegue"

        cellSelectBlock = { [weak self] (cell: UITableViewCell) in

            if let s = self {

                s.dataStore.perform({ (ds: CDSDataStore) in s.order.supplier = s.objectForCell(cell) as? Supplier; return nil }, withCompletion:nil)
            }
        }

        cellDeselectBlock = { [weak self] (cell: UITableViewCell) in

            if let s = self {

                s.dataStore.perform({ (ds: CDSDataStore) in s.order.supplier = nil; return nil }, withCompletion:nil)
            }
        }

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "Supplier", sortDescriptors: sortDescArray, mocToObserve: dataStore.managedObjectContext)

        // Assign it an update block
        dataFetchController.cellUpdateBlock = { [weak self] (cell: UITableViewCell?, object: AnyObject) in if let c = cell { return self?.configureCell(c, withObject: object) } else { return nil }}
        dataFetchController.name = "Supplier DFC"

        // Fetch and reload Data.
        dataFetchController.fetchWithCompletion(nil)
    }

    // MARK: Cell config.

    func supplierIsChecked(_ supplier: Supplier) -> Bool {

        guard let os = self.order.supplier else { return false }

        return os == supplier
    }

    override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        guard let supplier = object as? Supplier, let supplierCell = cell as? SupplierCell else { return cell }

        var params: (sn: String?, an: String?, ea: String?, checked: Bool) = ("", "", "", false)

        self.dataStore.perform({ (ds: CDSDataStore) in

            params.sn = supplier.name
            params.an = supplier.accountNumber
            params.ea = supplier.emailAddress

            params.checked = self.supplierIsChecked(supplier)

            return nil

            }, withCompletion: { _ in

                supplierCell.nameLabel.text = params.sn
                supplierCell.accountNumberLabel.text = params.an
                supplierCell.emailAddressLabel.text = params.ea

                if params.checked { cell.accessoryType = .checkmark } else { cell.accessoryType = .none }
        })

        return supplierCell
    }
    
    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        if let detailViewController = segue.destination as? SupplierDetailViewController {

            // Is this an edit operation? Check the name of the segue to find out.
            if segue.identifier == editSegueName {

                // Get the supplier involved from the segue sender
                if let supplier = sender as? Supplier {

                    detailViewController.loadBlock = { (stvc: StaticTableViewController) in guard let vc = stvc as? SupplierDetailViewController else { return }

                        vc.navigationItem.title = "Edit Supplier"

                        var params: (sn: String?, ea: String?, an: String?) = ("", "", "")

                        vc.dataStore.perform({ (ds: CDSDataStore) in

                            params.sn = supplier.name
                            params.ea = supplier.emailAddress
                            params.an = supplier.accountNumber

                            return nil

                            }, withCompletion: { _ in

                                vc.supplierNameField.text = params.sn
                                vc.emailAddressField.text = params.ea
                                vc.accountNumberField.text = params.an
                        })
                    }

                    detailViewController.editBlock = { (stvc: StaticTableViewController) in guard let vc = stvc as? SupplierDetailViewController else { return }

                        let sn = vc.supplierNameField.text
                        let ea = vc.emailAddressField.text
                        let an = vc.accountNumberField.text

                        vc.dataStore.perform({ (ds: CDSDataStore) in

                            if sn != supplier.name { supplier.name = sn }
                            if ea != supplier.emailAddress { supplier.emailAddress = ea }
                            if an != supplier.accountNumber { supplier.accountNumber = an }

                            return nil
                            
                            }, withCompletion:nil)
                    }
                }
                
            } else {

                // After a new supplier is added and saved, reload the table data so that we can get the correct check mark.
                detailViewController.saveBlock = { [weak self] (stvc: StaticTableViewController) in guard let s = self, let vc = stvc as? SupplierDetailViewController else { return }

                    // Get values from the detail viewcontroller
                    let sn = vc.supplierNameField.text ?? "Unnamed Supplier"
                    let ea = vc.emailAddressField.text ?? "unnamed@supplier.com"
                    let an = vc.accountNumberField.text ?? "00000"

                    vc.dataStore.perform({ (ds: CDSDataStore) in

                        // Saving so let's create a new lens
                        if let newSupplier = vc.dataStore.addSupplier(withName: sn, acctNumber: an, email: ea) {

                            // Table completion block will scroll to the correct row
                            s.dataFetchController.tableUpdateCompletionBlock = { (tv: UITableView) in

                                if let ip = s.indexPathForObject(newSupplier) { tv.scrollToRow(at: ip, at: .middle, animated: true) }

                                // This will be a one-shot operation
                                return true
                            }

                            vc.order.supplier = newSupplier
                        }

                        return nil
                        
                    }, withCompletion:nil)
                }
            }
        }
    }
}

//
// MARK: - Supplier cell
//
// Has not yet been documented.
//

class SupplierCell : UITableViewCell {

    // UI

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
}

//
// MARK: - Supplier Detail VC
//
// Has not yet been documented.
//

class SupplierDetailViewController : StaticTableViewController {

    // MARK: Properties

    @IBOutlet weak var accountNumberField: UITextField!
    @IBOutlet weak var supplierNameField: UITextField!
    @IBOutlet weak var emailAddressField: UITextField!
}
