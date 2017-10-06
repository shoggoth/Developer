//
//  WatchlistRootViewController.swift
//  BetMe
//
//  Created by Rich Henry on 13/04/2017.
//  Copyright © 2017 Rich Henry. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack
import UISupport

class WatchlistRootViewController : DataFetchTableViewController {

    private let coreDataStack = AppDelegate.coreDataStack

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        coreDataStack.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        fetchedResultsController = {

            let fetcher = ObjectFetcher<WatchlistItem>(observingContext: coreDataStack.persistentContainer.viewContext)

            fetcher.cellConfigBlock = { cell, obj in

                cell.textLabel?.text = obj?.displayTitle
                cell.detailTextLabel?.text = obj?.marketID

                return cell
            }

            fetcher.objectDeleteBlock = { object in object?.deleteAndSave() }

            fetcher.changeHandler = MegaTableFetchChangeHandler(withTableView: self.tableView)

            fetcher.fetch { _ in self.tableView.reloadData() }

            return fetcher
        }()
    }

    // MARK: Actions

    @IBAction func activateSettingsSheet(_ sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Database things", message: "Got some database operations in this action sheet for your edification and entertainment.", preferredStyle: .actionSheet)

        let listAction = UIAlertAction(title: "List To Console", style: .default) { alertAction in

            let fetch: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()

            self.coreDataStack.persistentContainer.performBackgroundTask { context in

                let arr = try! fetch.execute()

                print("res = \(arr)")
                print("ctx = \(context)")
            }
        }

        let refreshAction = UIAlertAction(title: "Refresh", style: .default) { _ in self.tableView.reloadData() }
        let dropAction = UIAlertAction(title: "Delete all", style: .destructive) { _ in self.coreDataStack.batchDeleteObjects(ofType: "WatchlistItem") }
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { alertAction in print("action 3 = \(alertAction.title)") }

        alertController.addAction(listAction)
        alertController.addAction(refreshAction)
        alertController.addAction(dropAction)
        //alertController.addAction(cancelAction)

        alertController.popoverPresentationController?.barButtonItem = sender

        self.present(alertController, animated: true)
    }

    @IBAction func addSomething(sender: UIBarButtonItem) {

        let viewContext = coreDataStack.persistentContainer.viewContext
        let user = WatchlistItem(context: viewContext)

        user.marketID  = "Manually added"
        user.displayTitle = "Manually added"

        try! viewContext.save()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let view = sender as? UIView, let indexPath = tableView.indexPath(forCellContentView: view) {

            (segue.destination as? MarketInjectable)?.market = Market(data: ["id": tableView.cellForRow(at: indexPath)?.detailTextLabel?.text ?? ""])
        }
    }

    // MARK: Temp

    func addAnEntryEveryTenSeconds(fetcher: ObjectFetcher<WatchlistItem>) {

        fetcher.fetch { _ in

            self.tableView.reloadData()

            self.coreDataStack.persistentContainer.performBackgroundTask { context in

                while true {

                    let watchlistItem = WatchlistItem(context: context)

                    watchlistItem.marketID  = "Added From Background"
                    watchlistItem.displayTitle = "Added From Background 10s"

                    try! context.save()

                    Thread.sleep(forTimeInterval: 10.0)
                }
            }
        }
    }
}
