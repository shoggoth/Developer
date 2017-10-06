//
//  LadderViewController.swift
//  BetMe
//
//  Created by Rich Henry on 14/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

class LadderContainerViewController : UIViewController {

    internal var entry: [String : Any] = [:]

    private let session = BetMeServerSession.sharedInstance
    private let accountID = AccountManager.sharedInstance.defaultAccount?.accountID

    private var tableViewController: LadderViewController? = nil

    @IBOutlet weak var marketEntryLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        subscribe()

        marketEntryLabel.text = entry["market_entry_name"] as? String
    }

    override func viewWillDisappear(_ animated: Bool) {

        if self.isBeingDismissed || self.isMovingFromParentViewController { unsubscribe() }

        super.viewWillDisappear(animated)
    }

    // MARK: Un/Subscribe To Changes

    private func subscribe() {

        // Subscribe to change notifications
        if let entryID = entry["market_entry_id"] as? String {

            session.subscribe(toEntry: entryID) { result in

                // Extract the initial state of the entry.
                if let result = result as? [String : Any] {

                    if let prices = result["prices"] as? [[String : Any]] { self.tableViewController?.deltaPrices(withValues: prices) }

                    self.tableViewController?.tableView.reloadData()
                    self.tableViewController?.scrollToDefaultPosition()

                    self.session.connection.addObserver(forNotificationNamed: entryChangedNotificationKey, object: self, sel: #selector(self.entryChangeNotification))
                }
            }
        }
    }

    private func unsubscribe() {

        // Unsubscribe from notifications
        if let entryID = entry["market_entry_id"] as? String {

            session.unsubscribe(fromEntry: entryID) { _ in

                self.session.connection.removeObserver(forNotificationNamed: entryChangedNotificationKey, object: self)
            }
        }
    }

    // MARK: Notification

    func entryChangeNotification(note: Notification) {

        // Get the market entries contained in the change notification.
        if let result = note.userInfo?["result"] as? [String : Any] {

            if let prices = result["prices"] as? [[String : Any]] { self.tableViewController?.deltaPrices(withValues: prices, refreshAffectedTableCells: true) }
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ladderTableContainer" {

            // Table view controller contained
            tableViewController = segue.destination as? LadderViewController

            tableViewController?.betLayBlock = { [weak self] betLay, odds in

                self?.placeBet(backOrLay: betLay, odds: odds)
            }
        }
    }

    private func placeBet(backOrLay: Bool, odds: String) {

        if let entryID = entry["market_entry_id"] as? String, let accountID = self.accountID {

            session.placeBet(forMarketEntryID: entryID, accountID: accountID, price: Decimal(string: odds)!, size: Decimal(string: "10.00")!, back: backOrLay) { _ in }
        }
    }
}

// MARK: -

class LadderViewController: UITableViewController {

    internal var betLayBlock: ((Bool, String) -> Void)?

    private let rowCount = 350
    private var prices = [Decimal : [String : Any?]]()

    // MARK: Actions

    @IBAction func betLayButtonPressed(_ sender: UIButton) {

        if let indexPath = tableView.indexPath(forCellContentView: sender) {

            betLayBlock?(sender.tag == 1, LadderOdds.oddsString(forLadderIndex: indexPath.row + 1, withLadderRungs: rowCount))
        }
    }

    // MARK: Data access

    func deltaPrices(withValues deltas: [[String : Any?]], refreshAffectedTableCells: Bool = false) {

        var rowsToRefresh = [IndexPath]()

        for delta in deltas {

            if let price = delta["price"] as? String, let decimalPrice = Decimal(string: price) {

                prices[decimalPrice] = delta

                if refreshAffectedTableCells, let rowToRefresh = LadderOdds.oddsIndex(forOdds: decimalPrice, withLadderRungs: rowCount) { rowsToRefresh.append(IndexPath(row: rowToRefresh, section: 0)) }
            }
        }

        self.tableView.reloadRows(at: rowsToRefresh, with: .top)
    }

    func scrollToDefaultPosition() {

        tableView.scrollToRow(at: IndexPath(row: rowCount - 1, section: 0), at: .bottom, animated: false)
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return rowCount }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        // Configure the cell…
        if let cell = cell as? LadderCell {

            let oddsString = LadderOdds.oddsString(forLadderIndex: indexPath.row + 1, withLadderRungs: rowCount)

            if let odds = Decimal(string: oddsString) {

                cell.oddsLabel.text = oddsString

                if let price = prices[odds] {

                    cell.layLabel.text = price["unmatched_total_size_for"] as? String ?? ""
                    cell.backLabel.text = price["unmatched_total_size_against"] as? String ?? ""

                } else {

                    cell.layLabel.text = ""
                    cell.backLabel.text = ""
                }
            }
        }
        
        return cell
    }
}

// MARK: -

class LadderCell : UITableViewCell {

    @IBOutlet weak var oddsLabel: UILabel!
    @IBOutlet weak var layLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
}
