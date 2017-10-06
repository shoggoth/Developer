//
//  LensMasterTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 27/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class LensMasterTableViewController: UITableViewController {

    // MARK: Properties
    var order: LensOrder!
    var whichLens: WhichLens = .Left

    // Core data fetchers
    private var dataFetchController: DataFetchController!

    // Internal
    private var checkedPath : NSIndexPath? = nil

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "manufacturer.name", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "Lens", sortDescriptors: sortDescArray)

        // Do the initial fetch
        dataFetchController.fetch()

        // Set the target of the add button after creating it.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTapped:")

        // Long Press for editing existing lenses.
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "handleLongPress:"))
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        // Reload the table data in case another view controller has changed one of the order's contents.
        tableView.reloadData()

        // Check the selected
        var lensToSelect : Lens?
        switch self.whichLens {

        case .Left: fallthrough
        case .Both:
            lensToSelect = self.order.leftLens

        case .Right:
            lensToSelect = self.order.rightLens
        }

        if let lens = lensToSelect { checkedPath = dataFetchController.fetchedResultsController.indexPathForObject(lens) }
    }

    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)

        if order != nil { IDDispensingDataStore.defaultDataStore().save() }
    }

    // MARK: Actions

    @IBAction func addButtonTapped(sender: UIBarButtonItem) {

        performSegueWithIdentifier("pushLensDetail", sender: self)
    }

    func handleLongPress(sender: UIGestureRecognizer) {

        if sender.state == .Began {

            let point = sender.locationInView(tableView)
            let indexPath = tableView.indexPathForRowAtPoint(point)

            performSegueWithIdentifier("pushLensDetail", sender: indexPath)
        }
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let segueID = segue.identifier {

            switch segueID {

            case "pushLensDetail":

                let detailViewController = segue.destinationViewController as! LensDetailViewController

                if let indexPath = sender as? NSIndexPath {

                    detailViewController.order = nil
                    detailViewController.lens = self.dataFetchController.fetchedResultsController.objectAtIndexPath(indexPath) as? Lens

                } else {

                    detailViewController.order = order
                    detailViewController.whichLens = whichLens

                    detailViewController.lens = nil
                }

            default: break
            }
        }
    }
    
    // MARK: Cell config.

    func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let lens = object as! Lens
        let lensCell = cell as! LensCell

        lensCell.nameLabel.text = "\(lens.name)"
        lensCell.typeLabel.text = lens.typeString()
        lensCell.priceLabel.text = lens.priceString()
        lensCell.materialLabel.text = lens.materialString()

        return lensCell
    }

    // MARK: Table view data source

    override func tableView(view: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        var cellSelectBlock: ((cell: UITableViewCell) -> Void) = { (cell: UITableViewCell) in

            // Select and save frame to order
            cell.accessoryType = .Checkmark
            if let lens = self.dataFetchController.fetchedResultsController.objectAtIndexPath(indexPath) as? Lens {

                switch self.whichLens {

                case .Left:
                    self.order.leftLens = lens

                case .Right:
                    self.order.rightLens = lens

                case .Both:
                    self.order.leftLens = lens
                    self.order.rightLens = lens
                }
            }

            self.checkedPath = indexPath
        }

        var cellDeselectBlock: ((cell: UITableViewCell) -> Void) = { (cell: UITableViewCell) in

            // Deselect and remove frame from order
            cell.accessoryType = .None

            switch self.whichLens {

            case .Left:
                self.order.leftLens = nil

            case .Right:
                self.order.rightLens = nil

            case .Both:
                self.order.leftLens = nil
                self.order.rightLens = nil
            }

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

    override func tableView(view: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("LensCell") as! UITableViewCell

        configureCell(cell, withObject: dataFetchController.fetchedResultsController.objectAtIndexPath(indexPath))

        if indexPath == checkedPath { cell.accessoryType = .Checkmark } else { cell.accessoryType = .None }

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
// MARK: - Lens cell
//
// Has not yet been documented.
//

class LensCell : UITableViewCell {

    // UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var materialLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
}

enum WhichLens {

    case Left, Right, Both
}

