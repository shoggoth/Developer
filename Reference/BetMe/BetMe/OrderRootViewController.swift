//
//  OrderRootViewControllerTableViewController.swift
//  BetMe
//
//  Created by Rich Henry on 11/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack

class OrderOptionsViewController : UITableViewController {

    @IBOutlet weak var marketTextField: UITextField!

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        (segue.destination as? MarketInjectable)?.market = Market(data: ["id" : marketTextField.text ?? ""])
    }
}

class OrderRootViewController: DataFetchTableViewController {

    private let coreDataStack = AppDelegate.coreDataStack
    private let serverSession = BetMeServerSession.sharedInstance

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        coreDataStack.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        fetchedResultsController = {

            let fetcher = ObjectFetcher<WatchlistItem>(observingContext: coreDataStack.persistentContainer.viewContext)

            fetcher.cellConfigBlock = { cell, watchlistEntry in

                cell.textLabel?.text = "\(String(describing: watchlistEntry?.marketID)) - \(watchlistEntry?.displayTitle ?? "Unnamed")"

                return cell
            }

            fetcher.objectDeleteBlock = { object in object?.deleteAndSave() }

            fetcher.changeHandler = TableFetchChangeHandler(withTableView: self.tableView)

            return fetcher
        }()

        let fetchContext = coreDataStack.persistentContainer.newBackgroundContext()

        //fetchAll(fromContext: fetchContext)
        coreDataStack.batchDeleteObjects(ofType: "WatchlistItem")
        fetchChanges(fromContext: fetchContext)
    }

    func fetchChanges(fromContext context: NSManagedObjectContext) {

        fetchedResultsController?.fetch { _ in

            self.serverSession.getGroupPathChildren(forGroupPathID: "0") { result in

                if let groupList = result["children"] as? [[String : Any]] {

                    context.perform {

                        for group in groupList {

                            if let groupID = group["id"] as? String, let groupName = group["name"] as? String {

                                // See if the object is in the database already
                                let fetchRequest: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()

                                fetchRequest.fetchLimit = 1
                                fetchRequest.predicate = NSPredicate(format: "(marketID == %@) AND (displayTitle == %@)", groupID, groupName)

                                let count = try? context.count(for: fetchRequest)

                                if count == 0 {

                                    let watchlistEntry = WatchlistItem(context: context)

                                    watchlistEntry.marketID = groupID
                                    watchlistEntry.displayTitle = groupName
                                }
                            }
                        }

                        print("fetchChanges saving context \(context) \(context.hasChanges)")

                        if context.hasChanges { try! context.save() } else { DispatchQueue.main.async { self.tableView.reloadData() }}
                    }
                }
            }
        }
    }

    func fetchAll(fromContext context: NSManagedObjectContext) {

        coreDataStack.batchDeleteObjects(ofType: "GroupPath")

        fetchedResultsController?.fetch { _ in

            self.serverSession.getGroupPathChildren(forGroupPathID: "0") { result in

                if let groupList = result["children"] as? [[String : Any]] {

                    context.perform {

                        for group in groupList {

                            let watchlistEntry = WatchlistItem(context: context)

                            watchlistEntry.marketID = group["id"] as? String
                            watchlistEntry.displayTitle = group["name"] as? String
                        }

                        print("fetchAll saving context \(context) \(context.hasChanges)")

                        try! context.save()
                    }
                }
            }
        }
    }
}
