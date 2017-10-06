//
//  DataFetchController.swift
//  BetDotMe
//
//  Created by Rich Henry on 18/04/2017.
//  Copyright © 2017 Rich Henry. All rights reserved.
//

import CoreData

public protocol TableFetchController {

    // Sections
    var numberOfSections: Int { get }

    func headerTitle(forSection section: Int) -> String?
    func rowCount(forSection section: Int) -> Int

    // Tableview handling
    func configureCell(cell: UITableViewCell, atIndexPath: IndexPath) -> UITableViewCell
    func selectCell(cell: UITableViewCell)
    func deselectCell(cell: UITableViewCell)

    func deleteObject(atIndexPath: IndexPath)
    func insertObject(atIndexPath: IndexPath)

    // Data fetch
    func fetch(withCompletion completion: (([NSFetchRequestResult]?) -> Void)?)
}

public class TableFetchChangeHandler : NSObject, NSFetchedResultsControllerDelegate {

    public var tableView: UITableView?

    // MARK: Lifecycle

    public init(withTableView tv: UITableView) { tableView = tv }

    // MARK: NSFetchedResultsControllerDelegate Compliance

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        tableView?.reloadData()
    }
}

public class MegaTableFetchChangeHandler : TableFetchChangeHandler {

    public var updatesAreUserDriven = false
    public var rowAnimation: UITableViewRowAnimation = .automatic

    // MARK: NSFetchedResultsControllerDelegate Compliance

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)  {

        if !self.updatesAreUserDriven { tableView?.beginUpdates() }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {


        if !updatesAreUserDriven {

            switch type {

            case NSFetchedResultsChangeType(rawValue: 0)!: break

            case .insert:
                // FIXME: Xcode 7.0.1 / Swift 2.0  EXCEPTION BUG running iOS 8.x. Workaround from https://forums.developer.apple.com/message/59082#59082
                if indexPath == nil { tableView?.insertRows(at: [newIndexPath!], with: rowAnimation) }

            case .delete:
                if let ip = indexPath { tableView?.deleteRows(at: [ip], with: rowAnimation) }

            case .update:
                print("TODO")
                //_ = self.cellUpdateBlock?(tableView?.cellForRow(at: indexPath!), anObject as AnyObject)

            case .move:
                tableView?.deleteRows(at: [indexPath!], with: rowAnimation)
                tableView?.insertRows(at: [newIndexPath!], with: rowAnimation)
            }
        }
    }

    public override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        if self.updatesAreUserDriven { updatesAreUserDriven = false } else { tableView?.endUpdates() }
    }
}

public class ObjectFetcher<T : NSManagedObject> : TableFetchController {

    public var cellConfigBlock: (UITableViewCell, T?) -> UITableViewCell

    public var cellSelectBlock: ((UITableViewCell) -> Void)? = nil
    public var cellDeselectBlock: ((UITableViewCell) -> Void)? = nil

    public var objectInsertBlock: ((T?) -> Void)? = nil
    public var objectDeleteBlock: ((T?) -> Void)? = nil

    public private(set) var frc: NSFetchedResultsController<NSFetchRequestResult>

    public var predicate: NSPredicate? {

        get { return frc.fetchRequest.predicate }
        set { frc.fetchRequest.predicate = newValue }
    }

    public var sortDescriptors: [NSSortDescriptor]? {

        get { return frc.fetchRequest.sortDescriptors }
        set { frc.fetchRequest.sortDescriptors = newValue }
    }

    public var batchSize: Int {

        get { return frc.fetchRequest.fetchBatchSize }
        set { frc.fetchRequest.fetchBatchSize = newValue }
    }

    public var changeHandler: TableFetchChangeHandler? {

        didSet { frc.delegate = changeHandler }
    }

    // MARK: Lifecycle

    public init(observingContext moc: NSManagedObjectContext, sectionNameKeyPath keyPath: String? = nil) {

        let fetchRequest = T.fetchRequest()

        fetchRequest.sortDescriptors = []

        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: keyPath, cacheName: nil)

        cellConfigBlock = { (cell, object) in cell.textLabel?.text = "ObjectFetcher: Untyped object \(String(describing: object))"; return cell }
    }

    deinit {

        print("ObjectFetcher \(self) deiniting")
    }

    // MARK: FetchesObjects Compliance

    public var numberOfSections: Int { get { return frc.sections?.count ?? 0 } }

    public func headerTitle(forSection section: Int) -> String? { return frc.sections?[section].name }
    public func rowCount(forSection section: Int) -> Int { return frc.sections?[section].numberOfObjects ?? 0 }

    public func configureCell(cell: UITableViewCell, atIndexPath path: IndexPath) -> UITableViewCell { return cellConfigBlock(cell, object(forIndexPath: path)) }
    public func selectCell(cell: UITableViewCell) { cellSelectBlock?(cell) }
    public func deselectCell(cell: UITableViewCell) { cellDeselectBlock?(cell) }

    public func deleteObject(atIndexPath path: IndexPath) { objectDeleteBlock?(object(forIndexPath: path)) }
    public func insertObject(atIndexPath path: IndexPath) { objectInsertBlock?(object(forIndexPath: path)) }

    // MARK: Object Fetch

    public func fetch(withCompletion completion: (([NSFetchRequestResult]?) -> Void)?) {

        frc.managedObjectContext.perform {

            do { try self.frc.performFetch() }

            catch { reportError(error: error) }

            // Call the completion asynchronously on the main queue
            DispatchQueue.main.async(execute: {
                
                completion?(self.frc.fetchedObjects)
            })
        }
    }
    
    // MARK: Utility
    
    public func indexPath(forObject obj: T) -> IndexPath? { return frc.indexPath(forObject: obj) }
    
    public func object(forIndexPath path: IndexPath) -> T? { return frc.object(at: path) as? T }
}

