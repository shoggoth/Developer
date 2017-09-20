//
//  OrderTableViewController.swift
//  GroceryPopup
//
//  Created by Richard Henry on 27/03/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

import UIKit

class OrderTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate {

    // MARK: Properties

    var popPresentCompletionBlock : (() -> Void)? = { println("Complete") }
    var popDismissCompletionBlock : (() -> Void)? = { println("Dismiss!") }

    private var poc: UIPopoverController?
    private let lowerThaniOS8 = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) == .OrderedAscending

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 1 { presentPopupWithViewControllerNamed("GroceryNavViewController", fromIndexPath: indexPath) }
    }

    // MARK: Popup Control

    func presentPopupWithViewControllerNamed(named: String, fromIndexPath indexPath: NSIndexPath) {

        if let sb = storyboard {

            let vc = sb.instantiateViewControllerWithIdentifier(named) as! UIViewController

            if lowerThaniOS8 {

                poc = UIPopoverController(contentViewController: vc)

                if let popover = poc {

                    popover.delegate = self

                    let rect  = tableView.rectForRowAtIndexPath(indexPath)

                    dispatch_async(dispatch_get_main_queue(), {

                        popover.presentPopoverFromRect(rect, inView: self.tableView, permittedArrowDirections: .Any, animated: true)
                        self.popPresentCompletionBlock?()
                    })
                }

            } else {

                vc.modalPresentationStyle = .Popover

                if let poc = vc.popoverPresentationController {

                    poc.sourceView = tableView
                    poc.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
                    poc.permittedArrowDirections = .Any

                    poc.delegate = self

                    dispatch_async(dispatch_get_main_queue(), { self.presentViewController(vc, animated: true, completion: self.popPresentCompletionBlock) })
                }
            }
        }
    }

    // MARK: UIPopoverPresentationControllerDelegate (iOS 8)

    func popoverPresentationControllerShouldDismissPopover(popoverController: UIPopoverPresentationController) -> Bool {

        println("Dolan Thread?")

        return true
    }

    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {

        popDismissCompletionBlock?()
    }

    // MARK: UIPopoverControllerDelegate (iOS 7)

    func popoverControllerShouldDismissPopover(popoverController: UIPopoverController) -> Bool {
        
        println("Dolan Thread?")
        
        return true
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        
        popDismissCompletionBlock?()
    }
}

class GroceryTableViewController : UITableViewController {

    // MARK: Properties

    @IBOutlet weak var addButton: UIBarButtonItem!

    var cellSelectBlock : ((cell: UITableViewCell) -> Void)? = nil
    var cellDeselectBlock : ((cell: UITableViewCell) -> Void)? = nil

    // Internal
    private var checkedPath : NSIndexPath? = nil

    let arr1 = ["One", "Two", "Three", "Four", "Five", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "Blah", "Unicorn", "Dog", "Walk", "Fofdl", "Dfhfie", "End of file"]

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = editButtonItem()
    }

    // MARK: Table Datasource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arr1.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("GroceryCell")as! UITableViewCell

        cell.textLabel?.text = arr1[indexPath.row]

        return cell
    }

    // MARK: Table Interaction

    override func tableView(view: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        var cellSelectBlock: ((cell: UITableViewCell) -> Void) = { (cell: UITableViewCell) in

            // Select and save to order
            cell.accessoryType = .Checkmark
            self.cellSelectBlock?(cell: cell)
            
            self.checkedPath = indexPath
        }

        var cellDeselectBlock: ((cell: UITableViewCell) -> Void) = { (cell: UITableViewCell) in

            // Deselect and remove from order
            cell.accessoryType = .None
            self.cellDeselectBlock?(cell: cell)
            self.checkedPath = nil
        }

        if let cell = view.cellForRowAtIndexPath(indexPath) {

            if let cp = checkedPath {

                // Deselect previously checked cell
                view.cellForRowAtIndexPath(cp)?.accessoryType = .None

                if checkedPath == indexPath { cellDeselectBlock(cell: cell) } else { cellSelectBlock(cell: cell) }

            } else { cellSelectBlock(cell: cell) }
        }
        
        return indexPath
    }

    // MARK: Table Edit

    override func tableView(view: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    override func tableView(view: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        // Return false if you do not want the specified item to be editable.
        return true
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let dvc = segue.destinationViewController as? GroceryAddViewController {

            dvc.saveBlock = { println("Save Passed from \(self)") }
        }
    }
}

class GroceryAddViewController : UIViewController {

    // MARK: Properties

    var loadBlock : (() -> Void)? = nil
    var saveBlock : (() -> Void)? = nil
    var killBlock : (() -> Void)? = nil

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save:")

        loadBlock?()
    }

    // MARK: Actions

    func save(sender: UIBarButtonItem) {

        saveBlock?()

        // Dismiss this view controller
        navigationController?.popViewControllerAnimated(true)
    }

    func cancel(sender: UIBarButtonItem) {

        killBlock?()

        // Dismiss this view controller
        navigationController?.popViewControllerAnimated(true)
    }
}