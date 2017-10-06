//
//  OrderMasterTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 07/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: Order master table view controller
//
// Has not yet been documented.
//

class OrderMasterTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    // MARK: Properties

    // UI
    @IBOutlet weak var addButton: UIBarButtonItem?

    @IBOutlet weak var orderTotalView: UIView!
    @IBOutlet var orderTotalLabels: [UILabel]!

    // Core data fetcher
    fileprivate var dataStore: IDDispensingDataStore = IDDispensingDataStore.default()
    fileprivate var dataFetchController: DataFetchController!

    // Search Controller (iOS 8 style)
    fileprivate var searchController: UISearchController!

    // Purchases
    fileprivate var unlocked: Bool = false

    // MARK: Lifecycle

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set up the master data fetch controller
        let sortDescs = [NSSortDescriptor(key: "date", ascending: false)]
        dataFetchController = DataFetchController(tableView: tableView, entityName: "Order", sortDescriptors: sortDescs, mocToObserve: dataStore.managedObjectContext)
        // Set the update closure for the data fetch controller.
        dataFetchController.cellUpdateBlock = { (cell: UITableViewCell?, object: AnyObject) in if let c = cell { return self.configureCell(c, withObject: object) } else { return nil }}
        dataFetchController.name = "Order Master DFC"
        // Set the standard predicate (used to filter results to match the current practice UUID optionally)
        dataFetchController.predicate = NSPredicate(value: true)

        // Add the refresh control
        insertRefreshControl()

        // This is the way to set up a search bar and controller in iOS 8
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self

        // Set up the search bar
        searchController.searchBar.keyboardType = keyboardTypeForSearchScope()
        searchController.searchBar.scopeButtonTitles = [ "All", "On Hold", "Confirmed", "Ordered", "Received", "Collected"]
        searchController.searchBar.delegate = self

        // Add the search bar to the table view's header
        self.tableView.tableHeaderView = searchController.searchBar

        // Since the search view covers the table view when active, we make the table view controller define the presentation context
        self.definesPresentationContext = true
        searchController.searchBar.sizeToFit()

        // Set up purchase notifications.
        NotificationCenter.default.addObserver(self, selector:#selector(OrderMasterTableViewController.purchaseNotification(_:)), name:NSNotification.Name.IDIAPProductPurchased, object: nil)
        unlocked = IDInAppPurchases.sharedIAPStore().singleUserUnlocked || IDInAppPurchases.sharedIAPStore().multiUserUnlocked

        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = editButtonItem

        // Set the target of the add button if it is connected
        if let ab = addButton { ab.target = self; ab.action = #selector(OrderMasterTableViewController.addButtonTapped(_:)) }

        // Add the pull down view to the top of the table view
        insertOrderTotalView()

        // Perform the initial data fetch and reload the table when finished
        dataFetchController.fetchWithCompletion(nil)
    }

    // MARK: UI

    fileprivate func insertRefreshControl() {

        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(OrderMasterTableViewController.refreshPulled(_:)), for: .valueChanged)

        self.refreshControl = refreshControl
    }

    fileprivate func insertOrderTotalView() {

        // Load the subviews from the XIB
        UINib(nibName: "OrderTotalViews", bundle: nil).instantiate(withOwner: self, options: nil)

        orderTotalView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(orderTotalView)

        NSLayoutConstraint(item: orderTotalView, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTotalView, attribute: .centerX, relatedBy: .equal, toItem: tableView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTotalView, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTotalView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
    }

    // MARK: Actions

    func refreshPulled(_ sender: UIRefreshControl) {

        var totals = ("0.0", "0.0", "0.0", "0.0")
        self.dataStore.perform({ (cds: CDSDataStore) in

            let ds = self.dataStore

            totals.0 = NumberFormatter.localizedString(from: ds.fetchOrderTotals(from: (Date() as NSDate).today(), to: (Date() as NSDate).tomorrow()), number: .currency)
            totals.1 = NumberFormatter.localizedString(from: ds.fetchOrderTotals(from: (Date() as NSDate).firstDayOfWeek()), number: .currency)
            totals.2 = NumberFormatter.localizedString(from: ds.fetchOrderTotals(from: (Date() as NSDate).firstDayOfMonth()), number: .currency)
            totals.3 = NumberFormatter.localizedString(from: ds.fetchOrderTotals(from: (Date() as NSDate).firstDayOfYear()), number: .currency)

            return nil

            }, withCompletion: { _ in

                self.orderTotalLabels[0].text = totals.0
                self.orderTotalLabels[1].text = totals.1
                self.orderTotalLabels[2].text = totals.2
                self.orderTotalLabels[3].text = totals.3

                self.refreshControl?.endRefreshing()
        })
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {

        if !unlocked && dataStore.countEntitiesNamed("Order") > 4 {

            let alertController = UIAlertController(title: "Demo limit reached", message: "Buy the full version to add more orders", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)

            return
        }

        // Create and set up a new detail view controller.
        if let odvc = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailViewController {

            odvc.isNewOrder = true

            // Set up the save and cancel operations
            odvc.saveBlock = {

                // Save the order.
                self.dataStore.save()
            }

            odvc.cancelBlock = {

                // Cancel the order.
                self.dataStore.rollback()
            }

            // Put it in a nav controller.
            let navController = UINavigationController(rootViewController: odvc)
            navController.modalPresentationStyle = .pageSheet

            // Create an empty order
            dataStore.addOrder(completionBlock: { (order: Any?) in

                if let order = order as? Order {

                    odvc.order = order
                    self.present(navController, animated: true, completion: nil)
                }
            })
        }
    }

    func purchaseNotification(_ note: Notification) {

        // There has been a purchase so we might have to enable the share button.
        unlocked = IDInAppPurchases.sharedIAPStore().singleUserUnlocked || IDInAppPurchases.sharedIAPStore().multiUserUnlocked
    }

    // MARK: Utility

    func scrollToBottom() {

        self.tableView.scrollRectToVisible(CGRect(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height), animated: true)
    }

    // MARK: Cell config.

    func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        guard let order = object as? Order, let orderCell = cell as? OrderCell else { return cell }

        var params: (on: String, pn: String, cd: String, sn: String, ld: String, fd: String, tp: String) = ("", "", "", "", "", "", "")

        self.dataStore.perform({ (ds: CDSDataStore) in

            params.on = order.prefixedOrderNumber
            params.pn = order.patientFullName()
            params.cd = order.creationDateString(.shortStyle)
            params.sn = order.statusName()
            params.ld = order.lensDescription()
            params.fd = order.frameDescription()
            params.tp = order.totalPriceString()

            return nil

            }, withCompletion: { _ in

                orderCell.orderNumberLabel.text = params.on
                orderCell.nameLabel.text = params.pn
                orderCell.dateLabel.text = params.cd
                orderCell.orderStatusLabel.text = params.sn
                orderCell.lensLabel.text = params.ld
                orderCell.frameLabel.text = params.fd
                orderCell.priceLabel.text = params.tp
        })

        return cell
    }

    // MARK: Table view data source

    override func tableView(_ view: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Create and set up a new detail view controller.
        if let odvc = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailViewController {

            if let order = dataFetchController.fetchedResultsController.object(at: indexPath) as? Order {

                odvc.order = order

                // Set up the save and cancel operations (No cancel block for edits)
                odvc.saveBlock = {

                    // Save the object and display the newly added record at the bottom of the table.
                    self.dataStore.save()
                }

                // Push it in the existing nav controller.
                navigationController?.pushViewController(odvc, animated: true)
            }
        }
    }

    override func tableView(_ view: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)

        let object = dataFetchController.fetchedResultsController.object(at: indexPath);

        _ = configureCell(cell, withObject: object)

        return cell
    }

    override func numberOfSections(in view: UITableView) -> Int {

        // The number of sections can be got from the fetched results controller.
        if let sections = dataFetchController.fetchedResultsController?.sections {

            return sections.count

        } else { return 0 }
    }

    override func tableView(_ view: UITableView, numberOfRowsInSection section: Int) -> Int {

        // The number of items in the section can also be gotten from the fetched results controller.
        if let sections = dataFetchController.fetchedResultsController?.sections {

            return sections[section].numberOfObjects
            
        } else { return 0 }
    }

    override func tableView(_ view: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

        // Return false if you do not want the specified item to be movable.
        return false
    }

    override func tableView(_ view: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        // Return false if you do not want the specified item to be editable.
        return unlocked
    }

    override func tableView(_ view: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            // Delete the object from the data source
            dataStore.delete(dataFetchController.fetchedResultsController.object(at: indexPath))
            dataStore.save()

        } else if editingStyle == .insert {
            
            // Create a new instance of the appropriate class and add a new row to the table view.
            // Unsure if this ever gets called. Used to be the line below.
            // dataStore.addOrder()
        }
    }
    
    // MARK: Fetched results updates

    fileprivate func keyboardTypeForSearchScope(_ scope: Int = 0) -> UIKeyboardType {

        return .default
    }


    fileprivate func predicateForSearch(_ mode: NSInteger, string: String) -> NSPredicate! {

        // Order status filter
        let modePredicate =  mode < 0 ? NSPredicate(value: true) : NSPredicate(format: "status = %d", mode)

        // Typed filter
        if string.isEmpty { return modePredicate } else {

            let basePredicate = NSPredicate(format: "patient.firstName CONTAINS[c] $searchTerm || patient.surName CONTAINS[c] $searchTerm || orderPrefix CONTAINS[c] $searchTerm || orderNumber == $searchTerm").withSubstitutionVariables(["searchTerm": string])

            return NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, modePredicate])
        }
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for controller: UISearchController) {

        if let searchString = controller.searchBar.text {

            dataFetchController.predicate = predicateForSearch(controller.searchBar.selectedScopeButtonIndex - 1, string: searchString)
            dataFetchController.fetchWithCompletion({(res: [AnyObject]?) in self.tableView.reloadData() })
        }
    }

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        searchBar.keyboardType = keyboardTypeForSearchScope(selectedScope)

        // Hack: force ui to reflect changed keyboard type
        if searchBar.resignFirstResponder() { searchBar.becomeFirstResponder() }
    }

    // MARK: UISearchControllerDelegate

    func didDismissSearchController(_ searchController: UISearchController) {

        dataFetchController.predicate = NSPredicate(value: true)
        dataFetchController.fetchWithCompletion({(res: [AnyObject]?) in self.tableView.reloadData() })
    }
}

//
// MARK: - Order cell
//
// Has not yet been documented.
//

class OrderCell : UITableViewCell {
    
    // UI

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var lensLabel: UILabel!
    @IBOutlet weak var frameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
}
