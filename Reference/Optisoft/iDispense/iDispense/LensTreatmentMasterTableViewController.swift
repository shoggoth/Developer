//
//  LensTreatmentMasterTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 27/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class LensTreatmentMasterTableViewController: UITableViewController {

    // MARK: Properties
    var order: LensOrder!
    var treatmentType: String!

    // Core data fetchers
    private var dataFetchController: DataFetchController!

    // Internal
    private var checkedCell: UITableViewCell? = nil

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Create the main data fetch controller
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "LensTreatment", sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        dataFetchController.predicate = NSPredicate(format: "type = %@", treatmentType)
        
        // Do the initial fetch
        dataFetchController.fetch()

        // Set the target of the add button after creating it.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTapped:")

    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Reload the table data in case another view controller has changed one of the order's contents.
        tableView.reloadData()
    }

    // MARK: Actions

    @IBAction func addButtonTapped(sender: UIBarButtonItem) {

        performSegueWithIdentifier("pushLensTreatmentDetail", sender: self)
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let segueID = segue.identifier {

            switch segueID {

            case "pushLensTreatmentDetail":

                let detailViewController = segue.destinationViewController as! LensTreatmentDetailViewController

                detailViewController.order = order

            default: break
            }
        }
    }
    
    // MARK: Cell config.

    func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let lensTreatment = object as! LensTreatment
        let lensTreatmentCell = cell as! LensTreatmentCell

        lensTreatmentCell.nameLabel.text = "\(lensTreatment.name)"
        lensTreatmentCell.priceLabel.text = lensTreatment.priceString()

        // Put in a check mark if this is the lens that's selected in the order.
//        var lensToMatch = treatmentType ? order.leftLens : order.rightLens
//
//        if lensToMatch != nil && lens == lensToMatch { cell.accessoryType = .Checkmark; checkedCell = cell }

        return lensTreatmentCell
    }

    // MARK: Table view data source

    override func tableView(view: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        if let cell = view.cellForRowAtIndexPath(indexPath) {

            // Deselect previously checked cell
            if checkedCell != nil { checkedCell!.accessoryType = .None }

            // Set the selected lens
            if let lens = dataFetchController.fetchedResultsController.objectAtIndexPath(indexPath) as? Lens {

//                if treatmentType { order.leftLens = lens } else { order.rightLens = lens }
            }

            // Check and save
            cell.accessoryType = .Checkmark
            checkedCell = cell
        }
        
        return indexPath
    }

    override func tableView(view: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("LensTreatmentCell") as! UITableViewCell

        configureCell(cell, withObject: dataFetchController.fetchedResultsController.objectAtIndexPath(indexPath))
        
        return cell
    }

    override func numberOfSectionsInTableView(view: UITableView) -> Int {

        // The number of sections can be got from the fetched results controller.
        if let sections = dataFetchController.fetchedResultsController.sections as? [NSFetchedResultsSectionInfo] {

            return sections.count

        } else { return 0 }
    }

    override func tableView(view: UITableView, numberOfRowsInSection section: Int) -> Int {

        // The number of items in the section can also be gotten from the fetched results controller.
        if let sections = dataFetchController.fetchedResultsController.sections as? [NSFetchedResultsSectionInfo] {

            return sections[section].numberOfObjects

        } else { return 0 }
    }

    override func tableView(view: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        // Return false if you do not want the specified item to be movable.
        return true
    }

    override func tableView(view: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        // Return false if you do not want the specified item to be editable.
        return true
    }
}

//
// MARK: - Lens treatment cell
//
// Has not yet been documented.
//

class LensTreatmentCell : UITableViewCell {

    // UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
}

