//
//  FrameSizeTableViewController.swift
//  iDispense
//
//  Created by Richard Henry on 20/02/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class FrameSizeTableViewController: UITableViewController {

    // MARK: Properties
    var order: Order!

    // Core data fetchers
    private var dataFetchController: DataFetchController!

    // Internal
    private var checkedCell: UITableViewCell? = nil

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Create the main data fetch controller
        let sortDescArray = [NSSortDescriptor(key: "sSize", ascending: true), NSSortDescriptor(key: "length", ascending: true), NSSortDescriptor(key: "bridge", ascending: true)]
        dataFetchController = DataFetchController(tableView: self.tableView, entityName: "FrameSize", sortDescriptors: sortDescArray, sectionNameKeyPath: nil)

        dataFetchController.predicate = NSPredicate(format: "frames CONTAINS %@", order.frame)

        // Do the initial fetch
        dataFetchController.fetch()

        // Set the target of the add button after creaating it.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonTapped:")
    }

    // MARK: Actions

    @IBAction func addButtonTapped(sender: UIBarButtonItem) {

        performSegueWithIdentifier("pushFrameSizeDetail", sender: self)
    }

    // MARK: Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let segueID = segue.identifier {

            switch segueID {

            case "pushFrameSizeDetail":

                let detailViewController = segue.destinationViewController as FrameSizeDetailViewController

                detailViewController.order = order

            default: break
            }
        }
    }

    // MARK: Cell config.

    func configureCell(cell: UITableViewCell, withObject object: AnyObject) -> UITableViewCell {

        let frameSize = object as FrameSize
        let frameSizeCell = cell as FrameSizeCell

        frameSizeCell.sizeLabel.text = "Size \(frameSize.sSize)"
        frameSizeCell.lengthLabel.text = "Length \(frameSize.length)"
        frameSizeCell.bridgeLabel.text = "Bridge \(frameSize.bridge)"

        // Put in a check mark if this is the frame that's selected in the order.
        if order.frameSize != nil && frameSize == order.frameSize { cell.accessoryType = .Checkmark; checkedCell = cell }

        return frameSizeCell
    }

    // MARK: Table view data source

    override func tableView(view: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        if let cell = view.cellForRowAtIndexPath(indexPath) {

            // Deselect previously checked cell
            if checkedCell != nil { checkedCell!.accessoryType = .None }

            // Set the selected frame
            order.frameSize = dataFetchController.fetchedResultsController.objectAtIndexPath(indexPath) as? FrameSize

            // Check and save
            cell.accessoryType = .Checkmark
            checkedCell = cell
        }
        
        return indexPath
    }

    override func tableView(view: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("FrameSizeCell") as UITableViewCell

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
}


//
// MARK: - Frame size cell
//
// Some spiel here about how this is the best table view controller that has ever been
// thought of for some of the time.
//

class FrameSizeCell : UITableViewCell {

    // UI
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var bridgeLabel: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
}

