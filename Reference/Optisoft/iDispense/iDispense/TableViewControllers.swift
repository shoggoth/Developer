//
//  TableViewControllers.swift
//  iDispense
//
//  Created by Richard Henry on 31/03/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

//
// MARK: Order TVC
//
// Has not yet been documented.
//

class OrderTableViewController : UITableViewController {

    // MARK: Properties

    internal var order: Order!

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // If we are segueing to another Order TVC from this one, pass on the order.
        if let dvc = segue.destination as? OrderTableViewController {

            // Always copy the order
            dvc.order = self.order
        }
    }
}

//
// MARK: - Dynamic Order TVC
//
// Has not yet been documented.
//

class DynamicTableViewController : OrderTableViewController {

    // MARK: Properties
    var canEditRows = true
    var canSelectMultipleRows = false

    var cellIdentifier: String = "DefaultCell"

    var dataFetchController: DataFetchController!
    var editSegueName: String? = nil

    let dataStore = IDDispensingDataStore.default()

    // Operation blocks
    var cellSelectBlock: ((_ cell: UITableViewCell) -> Void)? = nil
    var cellDeselectBlock: ((_ cell: UITableViewCell) -> Void)? = nil

    var objectInsertBlock: ((_ object: AnyObject?) -> Void)? = nil
    var objectDeleteBlock: ((_ object: AnyObject?) -> Void)? = nil

    // Private
    fileprivate var editCausedByEditButtonPress: Bool = false

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Display an Edit button in the navigation bar for this view controller.
        if canEditRows {

            self.navigationItem.leftBarButtonItem = editButtonItem
            self.navigationItem.leftBarButtonItem!.action = #selector(DynamicTableViewController.setEditingFromButton)
            tableView.allowsSelectionDuringEditing = true
        }

        // Default delete block.
        objectDeleteBlock = { [weak self] (object: AnyObject?) in self?.dataStore.delete(object) }
    }

    // MARK: Cell config.

    func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        cell.textLabel?.text = "DTVC: Untyped object \(object)"

        return cell
    }
    
    // MARK: Table Utility

    func indexPathForCell(_ cell: UITableViewCell) -> IndexPath? {

        return tableView.indexPath(for: cell)
    }

    func cellForIndexPath(_ path: IndexPath) -> UITableViewCell? {

        return tableView.cellForRow(at: path)
    }

    func indexPathForObject(_ object: NSManagedObject?) -> IndexPath? {

        if object == nil { return nil } else { return dataFetchController.fetchedResultsController.indexPath(forObject: object!) }
    }

    func objectForIndexPath(_ path: IndexPath) -> AnyObject? {

        if let ip = cellForIndexPath(path) { return objectForCell(ip) } else { return nil }
    }

    func objectForCell(_ cell: UITableViewCell) -> AnyObject? {

        if let indexPath = indexPathForCell(cell) { return dataFetchController.fetchedResultsController.object(at: indexPath) }

        return nil
    }

    // MARK: Table Datasource

    override func numberOfSections(in tableView: UITableView) -> Int {

        return dataFetchController.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if let sections = dataFetchController.fetchedResultsController.sections { return sections[section].name }

        return "???"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // The number of items in the section can also be gotten from the fetched results controller.
        if let sections = dataFetchController.fetchedResultsController.sections { return sections[section].numberOfObjects }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!

        // Do the cell configuration
        _ = configureCell(cell, withObject: dataFetchController.fetchedResultsController.object(at: indexPath))

        return cell
    }

    // MARK: Editing

    func setEditingFromButton() {

        editCausedByEditButtonPress = !isEditing
        setEditing(!isEditing, animated: true)
    }

    // MARK: Table Interaction
    
    override func tableView(_ view: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        if !tableView.isEditing {

            if let cellToSelect = view.cellForRow(at: indexPath) {

                let cellSelectBlock: ((_ cell: UITableViewCell) -> Void) = { [weak self] (cell: UITableViewCell) in

                    if let s = self {

                        // Select cell and call the select block
                        s.cellSelectBlock?(cell)

                        if s.cellDeselectBlock == nil { _ = s.navigationController?.popViewController(animated: true) }
                    }
                }

                let cellDeselectBlock: ((_ cell: UITableViewCell, _ cp: IndexPath) -> Void) = { [weak self] (cell: UITableViewCell, cp: IndexPath) in

                    // Deselect cell and call the deselect block.
                    self?.cellDeselectBlock?(cell)
                }

                if cellToSelect.accessoryType == .checkmark {

                    // Toggle the select state as this path is already checked.
                    cellDeselectBlock(cellToSelect, indexPath)

                } else { cellSelectBlock(cellToSelect) }
            }
        }

        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView.isEditing && editSegueName != nil { self.performSegue(withIdentifier: editSegueName!, sender: objectForIndexPath(indexPath)) }
    }

    // MARK: Table Edit

    override func tableView(_ view: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        // Return false if you do not want the specified item to be editable.
        return canEditRows
    }

    override func tableView(_ view: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        // Which object are we dealing with?
        let object: AnyObject? = dataFetchController.fetchedResultsController.object(at: indexPath)

        if editingStyle == .delete { objectDeleteBlock?(object) } else if editingStyle == .insert { objectInsertBlock?(object) }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        // Returning a nil causes just the standard delete button to be show.
        // This is what we will want in the case that there is not segue to an edit scene or the edit button was pressed.
        if editCausedByEditButtonPress || editSegueName == nil { return nil }

        // Add the edit buttons if they are needed
        let editButton = UITableViewRowAction(style: .normal, title: "Edit", handler: { [weak self] (action: UITableViewRowAction!, path: IndexPath!) in

            if let s = self { s.performSegue(withIdentifier: s.editSegueName!, sender: s.objectForIndexPath(path)) }
        })

        let deleteButton = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] (action: UITableViewRowAction!, path: IndexPath!) in

            if let s = self { s.objectDeleteBlock?(s.dataFetchController.fetchedResultsController.object(at: path)) }

        })

        return [deleteButton, editButton]
    }
}

//
// MARK: - Static Order TVC
//
// Has not yet been documented.
//

class StaticTableViewController : OrderTableViewController {

    // MARK: Properties

    // Operation blocks
    var loadBlock: ((_ stvc: StaticTableViewController) -> Void)? = nil
    var editBlock: ((_ stvc: StaticTableViewController) -> Void)? = nil
    var saveBlock: ((_ stvc: StaticTableViewController) -> Void)? = nil
    var killBlock: ((_ stvc: StaticTableViewController) -> Void)? = nil

    // Internals
    let dataStore = IDDispensingDataStore.default()

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Add the cancel and save buttons unless this is an edit
        if editBlock == nil {

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(StaticTableViewController.cancel(_:)))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(StaticTableViewController.save(_:)))
        }

        // This will remove extra separators from tableview
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        loadBlock?(self)
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // Commit the edits on leaving this view
        // First check that this view has disappeared due to the navigation button being pressed
        // rather than something like the user pressing outside to dismiss a pop-up
        if let viewControllers = self.navigationController?.viewControllers {

            if !viewControllers.contains(self) { editBlock?(self) }
        }
    }

    // MARK: Actions

    func save(_ sender: UIBarButtonItem) {
        
        saveBlock?(self)

        // Dismiss this view controller
        _ = navigationController?.popViewController(animated: true)
    }
    
    func cancel(_ sender: UIBarButtonItem) {
        
        killBlock?(self)

        // Dismiss this view controller
        _ = navigationController?.popViewController(animated: true)
    }
}
