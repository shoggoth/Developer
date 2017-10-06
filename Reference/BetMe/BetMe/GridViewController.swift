//
//  GridViewController.swift
//  BetMe
//
//  Created by Rich Henry on 31/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit
import CoreData
import UISupport

class GridViewController : UITableViewController, MarketInjectable {

    internal var market: Market?

    private var marketEntries: [[String : Any]] = []
    private var cellIdentifier = "MarketEntryCell"

    private let applyQueue = DispatchQueue(label: "me.bet.grid_apply_delta_queue")

    private let coreDataStack = AppDelegate.coreDataStack
    private let session = BetMeServerSession.sharedInstance

    private static let betLayButtonTagMappings = [(2, MarketEntry.unmatchedAgainstKey), (1, MarketEntry.unmatchedAgainstKey), (0, MarketEntry.unmatchedAgainstKey), (0, MarketEntry.unmatchedForKey), (1, MarketEntry.unmatchedForKey), (2, MarketEntry.unmatchedForKey)]

    @IBOutlet weak var bookmarkButton: UIBarButtonItem!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // TODO: Find a better way of doing this, peraps on logging in
        let _ = AccountManager.sharedInstance.defaultAccount?.accountID

        subscribe()

        let _ = isMarketInWatchlist()
    }

    override func viewWillDisappear(_ animated: Bool) {

        if self.isBeingDismissed || self.isMovingFromParentViewController { unsubscribe() }

        super.viewWillDisappear(animated)
    }

    // MARK: Un/Subscribe To Changes

    private func subscribe() {

        // Subscribe to change notifications
        if let marketID = market?.id {

            session.subscribe(toMarket: marketID) { result in

                // Extract the initial state of the entry.
                if let result = result as? [String : Any] {

                    // Subscribe to changes in the market
                    self.session.connection.addObserver(forNotificationNamed: marketChangedNotificationKey, object: self, sel: #selector(self.marketChangeNotification))

                    self.market?.data = result
                    self.marketEntries = self.market?.entries ?? []
                    self.navigationItem.title = self.market?.title

                    // Use auto-sizing of the table view cells.
                    let isHorseRacingMarket = self.market?.typeID == 13

                    self.cellIdentifier = isHorseRacingMarket ? "HorseRacingCell" : "MarketEntryCell"
                    self.tableView.estimatedRowHeight = isHorseRacingMarket ? 222 : 140
                    self.tableView.rowHeight = UITableViewAutomaticDimension

                    self.tableView.reloadData()
                }
            }
        }
    }

    private func unsubscribe() {

        // Unsubscribe from notifications
        if let marketID = market?.id {

            session.unsubscribe(fromMarket: marketID) { _ in

                self.session.connection.removeObserver(forNotificationNamed: marketChangedNotificationKey, object: self)
            }
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let view = sender as? UIView, let indexPath = tableView.indexPath(forCellContentView: view) {

            // Ladder for the selected entry
            (segue.destination as? LadderContainerViewController)?.entry = marketEntries[indexPath.row]
        }
    }

    // MARK: Notification

    func marketChangeNotification(note: Notification) {

        // Get the market entries contained in the change notification.
        if let result = note.userInfo?["result"] as? [AnyHashable : Any], let changes = result["market_entries"] as? [[String : Any]] {

            var rowsToRefresh = [IndexPath]()

            for change in changes {

                if let id = change["market_entry_id"] as? String {

                    // Find the original market entry that this relates to
                    for (index, marketEntry) in marketEntries.enumerated() {

                        if marketEntry["market_entry_id"] as? String == id {

                            let applyDeltas: (String) -> Void = { key in

                                self.marketEntries[index][key] = MarketEntry.apply(deltaList: change[key] as? [[String : Any?]?], toMarketEntryBets: marketEntry[key] as? [[String : Any]])
                            }

                            applyQueue.async {

                                applyDeltas(MarketEntry.unmatchedForKey)
                                applyDeltas(MarketEntry.unmatchedAgainstKey)

                                rowsToRefresh.append(IndexPath(row: index, section: 0))
                            }

                            break
                        }
                    }
                }
            }

            // Queue a refresh of the table rows that have changed.
            applyQueue.async { DispatchQueue.main.sync { self.tableView.reloadRows(at: rowsToRefresh, with: .top) } }
        }
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return marketEntries.count > 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return marketEntries.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Temporary
        (cell as? MarketEntryCell)?.stripView.backgroundColor = UIColor.lightGray
        (cell as? MarketEntryCell)?.entryNameLabel.text = entryDescription(forEntry: marketEntries[indexPath.row])

        // Get data entry for this row
        let entryData = marketEntries[indexPath.row]

        // Configure the cell…
        (cell as? MarketEntryCell)?.setBetLayButtonTitles(withEntryData: entryData, mappings: GridViewController.betLayButtonTagMappings)
        (cell as? HorseRacingCell)?.silkImageView.setURL(url: Silk.imageURL(fromEntryData: entryData), placeholderImage: #imageLiteral(resourceName: "UnknownSilk"))

        return cell
    }


    // MARK: Actions

    @IBAction func bookmarkButtonTapped(_ sender: UIBarButtonItem) {

        coreDataStack.persistentContainer.performBackgroundTask { context in

            let bookmark = WatchlistItem(context: context)

            bookmark.marketID  = self.market?.id
            bookmark.displayTitle = self.market?.title

            try! context.save()

            DispatchQueue.main.async { self.bookmarkButton.isEnabled = false }
        }
    }

    @IBAction func betLayButtonTapped(_ sender: UIButton) {

        guard let accountID = AccountManager.sharedInstance.defaultAccount?.accountID else { return }

        if let indexPath = tableView.indexPath(forCellContentView: sender) {

            // Get the market entry concerned
            let entry = MarketEntry(data: marketEntries[indexPath.row])

            if let entryID = entry.id {

                let mappingKey = GridViewController.betLayButtonTagMappings[sender.tag]

                if let price = entry.price(forMappingKey: mappingKey) ?? Decimal(string: "2"), let size = Decimal(string: "10.00") {

                    let back = mappingKey.1 == MarketEntry.unmatchedAgainstKey

                    session.placeBet(forMarketEntryID: entryID, accountID: accountID, price: price, size: size, back: back) { _ in }
                }
            }
        }

        if let cell = tableView.cell(forCellContentView: sender) as? MarketEntryCell { cell.stripView.backgroundColor = sender.tag < 3 ? UIColor.red : UIColor.green }
    }

    // MARK: Bookmarking

    private func isMarketInWatchlist() -> Bool {

        if let id = market?.id {

            let fetchRequest: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()

            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "(marketID == %@)", id)

            self.coreDataStack.persistentContainer.performBackgroundTask { context in

                if let count = try? context.count(for: fetchRequest) {

                    if count == 0 { DispatchQueue.main.async { self.bookmarkButton.isEnabled = true } }
                }
            }
        }

        return false
    }

    // MARK: Descriptions

    private func entryDescription(forEntry marketEntry: [String : Any]?) -> String {

        guard let entry = marketEntry else { return "Unknown" }

        let entryName = entry["market_entry_name"] as? String ?? ""
        let entryID = entry["market_entry_id"] as? String ?? ""

        return entryName + " - " + entryID
    }
}

// MARK: - Market Entry cell

class MarketEntryCell : UITableViewCell {
    
    @IBOutlet var betLayButtons: [UIButton]!
    
    @IBOutlet weak var stripView: UIView!
    @IBOutlet weak var entryNameLabel: UILabel!
    
    func setBetLayButtonTitles(withEntryData data: [String : Any], mappings: [(Int, String)]) {
        
        for button in betLayButtons {
            
            var title = "NOWT"
            
            if let matchArray = data[mappings[button.tag].1] as? [[String : Any?]] {
                
                let matchIndex = mappings[button.tag].0
                
                if matchIndex < matchArray.count {
                    
                    let bet = matchArray[matchIndex]
                    
                    title = "\(bet[MarketEntry.sizeKey] as? String ?? "0")@\(bet[MarketEntry.priceKey] as? String ?? "0.0")"
                }
            }
            
            button.setTitle(title, for: .normal)
        }
    }
}

// MARK: - Horse racing cell

class HorseRacingCell : MarketEntryCell {
    
    @IBOutlet weak var silkImageView: AsyncImageView!
}
