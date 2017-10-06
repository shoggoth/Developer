//
//  TableViewControllers.swift
//  BetDotMe
//
//  Created by Rich Henry on 18/04/2017.
//  Copyright © 2017 Rich Henry. All rights reserved.
//

import UIKit
import CoreData
//
// DataFetchTableViewController
//
// Has not yet been documented.
//

open class DataFetchTableViewController : UITableViewController {

    @IBInspectable var canEditRows: Bool = false
    @IBInspectable var canSelectMultipleRows: Bool = false
    @IBInspectable var cellIdentifier: String = "DefaultCell"

    public var editSegueName: String? = nil
    public var fetchedResultsController: TableFetchController?

    private var editCausedByEditButtonPress: Bool = false

    // MARK: Lifecycle

    override open func viewDidLoad() {

        super.viewDidLoad()

        // Display an Edit button in the navigation bar for this view controller.
        if canEditRows {

            self.navigationItem.leftBarButtonItem = editButtonItem
            self.navigationItem.leftBarButtonItem!.action = #selector(self.setEditingFromButton)
            tableView.allowsSelectionDuringEditing = true
        }
    }

    // MARK: Editing

    func setEditingFromButton() {

        editCausedByEditButtonPress = !isEditing
        setEditing(!isEditing, animated: true)
    }

    // MARK: Table Interaction

    override open func tableView(_ view: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        if !tableView.isEditing {

            if let cellToSelect = view.cellForRow(at: indexPath) {

                let cellSelectBlock: ((_ cell: UITableViewCell) -> Void) = { [weak self] (cell: UITableViewCell) in

                    // Select cell and call the select block
                    self?.fetchedResultsController?.selectCell(cell: cell)

                    //if s.objectFetcher?.cellDeselectBlock == nil { _ = s.navigationController?.popViewController(animated: true) }
                }

                let cellDeselectBlock: ((_ cell: UITableViewCell, _ cp: IndexPath) -> Void) = { [weak self] (cell: UITableViewCell, cp: IndexPath) in

                    // Deselect cell and call the deselect block.
                    self?.fetchedResultsController?.deselectCell(cell: cell)
                }

                if cellToSelect.accessoryType == .checkmark {

                    // Toggle the select state as this path is already checked.
                    cellDeselectBlock(cellToSelect, indexPath)

                } else { cellSelectBlock(cellToSelect) }
            }
        }

        return indexPath
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing && editSegueName != nil { self.performSegue(withIdentifier: editSegueName!, sender: (self, indexPath)) }
    }

    // MARK: Table Edit

    override open func tableView(_ view: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        // Return false if you do not want the specified item to be editable.
        return canEditRows
    }

    override open func tableView(_ view: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete { fetchedResultsController?.deleteObject(atIndexPath: indexPath) } else if editingStyle == .insert { fetchedResultsController?.insertObject(atIndexPath: indexPath) }
    }

    override open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        // Returning a nil causes just the standard delete button to be show.
        // This is what we will want in the case that there is not segue to an edit scene or the edit button was pressed.
        if editCausedByEditButtonPress || editSegueName == nil { return nil }

        // Add the edit buttons if they are needed
        let editButton = UITableViewRowAction(style: .normal, title: "Edit", handler: { [weak self] (action: UITableViewRowAction!, path: IndexPath!) in

            if let s = self { s.performSegue(withIdentifier: s.editSegueName!, sender: (self, indexPath)) }
        })

        let deleteButton = UITableViewRowAction(style: .default, title: "Delete", handler: { [weak self] (action: UITableViewRowAction!, path: IndexPath!) in

            if let s = self { s.fetchedResultsController?.deleteObject(atIndexPath: path) }
        })
        
        return [deleteButton, editButton]
    }
}

// MARK: Table View Datasource

extension DataFetchTableViewController {

    override open func numberOfSections(in tableView: UITableView) -> Int { return fetchedResultsController?.numberOfSections ?? 0 }

    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return fetchedResultsController?.headerTitle(forSection: section) }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return fetchedResultsController?.rowCount(forSection: section) ?? 0 }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!

        // Do the cell configuration
        return fetchedResultsController?.configureCell(cell: cell, atIndexPath: indexPath) ?? cell
    }
}

//
// StaticTableViewControllerWithEditableContent
//
// Has not yet been documented.
//

open class StaticTableViewControllerWithEditableContent : UITableViewController {

    // MARK: Properties

    // Operation blocks
    public var loadBlock: ((_ stvc: StaticTableViewControllerWithEditableContent) -> Void)? = nil
    public var editBlock: ((_ stvc: StaticTableViewControllerWithEditableContent) -> Void)? = nil
    public var saveBlock: ((_ stvc: StaticTableViewControllerWithEditableContent) -> Void)? = nil
    public var killBlock: ((_ stvc: StaticTableViewControllerWithEditableContent) -> Void)? = nil

    // MARK: Lifecycle

    override open func viewDidLoad() {

        super.viewDidLoad()

        // Add the cancel and save buttons unless this is an edit
        if editBlock == nil {

            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
        }

        // This will remove extra separators from tableview
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        loadBlock?(self)
    }

    override open func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        // Commit the edits on leaving this view
        // First check that this view has disappeared due to the navigation button being pressed
        // rather than something like the user pressing outside to dismiss a pop-up
        if let viewControllers = self.navigationController?.viewControllers {
            
            if !viewControllers.contains(self) { editBlock?(self) }
        }
    }
    
    // MARK: Segue

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // If we are segueing to another Order TVC from this one, pass on the order.
        if let dvc = segue.destination as? StaticTableViewControllerWithEditableContent {

            print("Destination view controller = \(dvc)")
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
