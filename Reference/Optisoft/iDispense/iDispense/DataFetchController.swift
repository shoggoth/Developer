//
//  DataFetchController.swift
//  iDispense
//
//  Created by Richard Henry on 09/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import CoreData
import UIKit

open class DataFetchController : NSObject, NSFetchedResultsControllerDelegate {

    // MARK: Properties
    open var name: String = "Unnamed DFC"
    open var fetchedResultsController : NSFetchedResultsController<NSManagedObject>!
    open var cellUpdateBlock: ((_ cell: UITableViewCell?, _ object: AnyObject) -> UITableViewCell?)?
    open var tableUpdateCompletionBlock: ((_ table: UITableView) -> Bool)?
    open var updatesAreUserDriven: Bool = false

    // MARK: Computed properties
    open var predicate : NSPredicate? {

        get { return fetchedResultsController.fetchRequest.predicate }
        set {
            if let cacheName = cacheName { NSFetchedResultsController<NSManagedObject>.deleteCache(withName: cacheName) }
            fetchedResultsController.fetchRequest.predicate = newValue
        }
    }
    
    open var sortDescriptors : [NSSortDescriptor]? {

        get { return fetchedResultsController.fetchRequest.sortDescriptors }
        set {
            if let cacheName = cacheName { NSFetchedResultsController<NSManagedObject>.deleteCache(withName: cacheName) }
            fetchedResultsController.fetchRequest.sortDescriptors = newValue
        }
    }
    
    // MARK: Private storage
    fileprivate let tableView: UITableView
    fileprivate let cacheName: String?

    // MARK: Private constant
    fileprivate let rowAnimation : UITableViewRowAnimation = .automatic

    // MARK: Lifecycle

    init(tableView: UITableView, entityName eName: String, sortDescriptors sortDescArray: [NSSortDescriptor], mocToObserve: NSManagedObjectContext, cacheName: String? = nil, sectionNameKeyPath secKeyPath: String? = nil) {

        // Keep the table view that the fetch is associated with.
        self.tableView = tableView
        self.cacheName = cacheName

        super.init()

        // Create and configure a fetch request with an entity type to fetch.
        let fetchRequest = NSFetchRequest<NSManagedObject>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: eName, in: mocToObserve)
        fetchRequest.sortDescriptors = sortDescArray

        // We are going to be using the results of the fetch in a table so let's have a small batch size
        fetchRequest.fetchBatchSize = 23

        // Create the fetched results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mocToObserve, sectionNameKeyPath: secKeyPath, cacheName: cacheName)
        fetchedResultsController.delegate = self
    }

    // MARK: Data fetch

    func fetchWithCompletion(_ completion: (([AnyObject]?) -> Void)?) {

        fetchedResultsController.managedObjectContext.performAndWait {

            do { try self.fetchedResultsController.performFetch() }
            catch { print("Error fetching") }

            // Call the completion asynchronously on the main queue
            DispatchQueue.main.async(execute: {

                completion?(self.fetchedResultsController.fetchedObjects)
            })
        }
    }

    // MARK: Fetched results updates
    // As we have changed to saving on a background thread, these calls to the delegate will also
    // be called on a thread that isn't the main thread so we should dispatch UI updates to the 
    // main thread.

    @objc open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)  {

        DispatchQueue.main.async(execute: { if !self.updatesAreUserDriven { self.tableView.beginUpdates() }})
    }

    @objc open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        DispatchQueue.main.async(execute: {

            if !self.updatesAreUserDriven {

                let tableView = self.tableView
                let rowAnimation = self.rowAnimation

                switch type {

                case NSFetchedResultsChangeType(rawValue: 0)!: break

                case .insert:
                    // FIXME: Xcode 7.0.1 / Swift 2.0  EXCEPTION BUG running iOS 8.x. Workaround from https://forums.developer.apple.com/message/59082#59082
                    if indexPath == nil { tableView.insertRows(at: [newIndexPath!], with: .automatic) }

                case .delete:
                    if let ip = indexPath { tableView.deleteRows(at: [ip], with: .automatic) }

                case .update:
                    _ = self.cellUpdateBlock?(tableView.cellForRow(at: indexPath!), anObject as AnyObject)

                case .move:
                    tableView.deleteRows(at: [indexPath!], with: rowAnimation)
                    tableView.insertRows(at: [newIndexPath!], with: rowAnimation)
                }
            }
        })
    }

    @objc open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)  {

        DispatchQueue.main.async(execute: {

            if self.updatesAreUserDriven { self.updatesAreUserDriven = false } else {

                self.tableView.endUpdates()

                // Call the completion block if there is one
                if let upCompletion = self.tableUpdateCompletionBlock {

                    if upCompletion(self.tableView) { self.tableUpdateCompletionBlock = nil }
                }
            }
        })
    }

    // Sections
    @objc open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        DispatchQueue.main.async(execute: {

            if !self.updatesAreUserDriven {

                let tableView = self.tableView
                let rowAnimation = self.rowAnimation

                switch type {

                case .insert:
                    tableView.insertSections(IndexSet(integer: sectionIndex), with: rowAnimation)

                case .delete:
                    tableView.deleteSections(IndexSet(integer: sectionIndex), with: rowAnimation)

                case .update, .move:
                    return
                }
            }
        })
    }
}
