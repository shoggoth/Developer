//
//  MasterTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 07/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: Master table view controller
//
// Some spiel here about how this is the best table view controller that has ever been
// thought of for some of the time.
//

class MasterTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    // MARK: Properties

    // UI
    @IBOutlet weak var addButton: UIBarButtonItem?

    // Core data fetchers
    private var dataFetchers: [UITableView: DataFetchController] = [:]

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set up the search controller if one has been specified
        if let searchDisplayController = self.searchDisplayController {

            searchDisplayController.searchBar.keyboardType = keyboardTypeForSearchScope()
        }

        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = editButtonItem()

        // Set the target of the add button if it is connected
        if let ab = addButton { ab.target = self; ab.action = "addButtonTapped:" }
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Reload the table data in case another view controller has changed one of the order's contents.
        tableView.reloadData()
    }

    // MARK: Stubs

    func addItem() {

        // This must be overriden
        NSException(name: "MissingOverrideException", reason: "addItem must be overriden", userInfo: nil).raise()
    }

    func selectItem(indexPath: NSIndexPath, inTableView view: UITableView) {

        // This must be overriden
        NSException(name: "MissingOverrideException", reason: "selectItem must be overriden", userInfo: nil).raise()
    }

    func dequeueCellForIndexPath(indexPath: NSIndexPath, withTableView view: UITableView) -> UITableViewCell {

        // This must be overriden
        NSException(name: "MissingOverrideException", reason: "dequeueCellForIndexPath must be overriden", userInfo: nil).raise()

        return UITableViewCell()
    }

    func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        // This must be overriden
        NSException(name: "MissingOverrideException", reason: "configureCell must be overriden", userInfo: nil).raise()

        return UITableViewCell(style: .Default, reuseIdentifier: nil)
    }

    func configureDataFetchControllerForTableView(view: UITableView) -> DataFetchController {

        // This must be overriden
        NSException(name: "MissingOverrideException", reason: "configureDataFetchControllerForTableView must be overriden", userInfo: nil).raise()

        return DataFetchController(tableView: view, entityName: "", sortDescriptors: [])
    }

    func predicateForSearch(mode: NSInteger, string: String) -> NSPredicate! {

        // Default to matching all.
        return NSPredicate(value: true)
    }

    // MARK: Actions

    @IBAction func addButtonTapped(sender: UIBarButtonItem) { addItem() }

    // MARK: Table utility

    func dataFetchControllerForTableView(view: UITableView) -> DataFetchController {

        if dataFetchers[view] == nil {

            // Create the data fetch controller and give it our table view.
            let newDataFetchController = configureDataFetchControllerForTableView(view)

            // Set the update closure for the data fetch controller.
            newDataFetchController.cellUpdateBlock = { (cell: UITableViewCell, object: AnyObject) in self.configureCell(cell, withObject: object) }
            newDataFetchController.cellCreateBlock = { (index: NSIndexPath) in return self.tableView.cellForRowAtIndexPath(index)! }

            // Perform the initial data fetch for the unfiltered results
            newDataFetchController.fetch()

            dataFetchers[view] = newDataFetchController
        }

        return dataFetchers[view]!
    }

    func scrollToBottom() {

        self.tableView.scrollRectToVisible(CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height), animated: true)
    }

    // MARK: UIViewController subclass

    override func setEditing(editing: Bool, animated: Bool) {

        super.setEditing(editing, animated: animated)

        // Disable the add button while we're doing the edits.
        addButton?.enabled = !editing
    }

    // MARK: Table view data source

    override func numberOfSectionsInTableView(view: UITableView) -> Int {

        // The number of sections can be got from the fetched results controller.
        if let sections = dataFetchControllerForTableView(view).fetchedResultsController?.sections as? [NSFetchedResultsSectionInfo] {

            return sections.count

        } else { return 0 }
    }

    override func tableView(view: UITableView, numberOfRowsInSection section: Int) -> Int {

        // The number of items in the section can also be gotten from the fetched results controller.
        if let sections = dataFetchControllerForTableView(view).fetchedResultsController?.sections as? [NSFetchedResultsSectionInfo] {

            return sections[section].numberOfObjects

        } else { return 0 }
    }

    override func tableView(view: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { selectItem(indexPath, inTableView: view) }

    override func tableView(view: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = dequeueCellForIndexPath(indexPath, withTableView: view)

        configureCell(cell, withObject: dataFetchControllerForTableView(view).fetchedResultsController.objectAtIndexPath(indexPath))

        return cell
    }

    override func tableView(view: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        // Return false if you do not want the specified item to be movable.
        return true
    }

    override func tableView(view: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(view: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {

            // Delete the object from the data source
            IDDispensingDataStore.defaultDataStore().deleteObject(dataFetchControllerForTableView(view).fetchedResultsController.objectAtIndexPath(indexPath))

        } else if editingStyle == .Insert {

            // Create a new instance of the appropriate class and add a new row to the table view.
            IDDispensingDataStore.defaultDataStore().createOrder()
        }

        // Save and reenable tracking of the object model.
        IDDispensingDataStore.defaultDataStore().save()
    }

    // MARK: Fetched results updates

    private func keyboardTypeForSearchScope(scope: Int = 0) -> UIKeyboardType {

        if scope == 1 { return .PhonePad }

        return .Default
    }

    // MARK: Search delegates

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        searchBar.keyboardType = keyboardTypeForSearchScope(scope: selectedScope)

        // Hack: force ui to reflect changed keyboard type
        searchBar.resignFirstResponder() && searchBar.becomeFirstResponder()
    }

    func searchDisplayController(controller: UISearchDisplayController, didLoadSearchResultsTableView view: UITableView) {

        // Match the search result row height to the height of the original table view (the non-filtered version)
        view.rowHeight = self.tableView.rowHeight
    }

    func searchDisplayController(controller: UISearchDisplayController, didHideSearchResultsTableView view: UITableView) {

        // Got to have some form of predicate in the data fetcher so return one that matches nothing in the data.
        // This should stop the data fetch controller associated with the search results table fetching results when the data model is altered
        // in the main table, hopefully. (Yes, this seems to be the solution to the problem I just mentioned.)
        dataFetchControllerForTableView(view).predicate = NSPredicate(value: false)
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {

        dataFetchControllerForTableView(controller.searchResultsTableView).predicate = predicateForSearch(controller.searchBar.selectedScopeButtonIndex, string: searchString)
        
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        
        dataFetchControllerForTableView(controller.searchResultsTableView).predicate = predicateForSearch(searchOption, string: controller.searchBar.text)
        
        return true
    }
}
