//
//  SubscriptionNotifier.swift
//  BetMe
//
//  Created by Rich Henry on 04/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

class SubscriptionNotifier {

    private var marketSubscriptions: [String : () -> Void] = [:]

    private let session: ServerSession

    init(withSession ses: ServerSession = BetMeServerSession.sharedInstance) {

        session = ses
    }

    func subscribe(toMarket market: Market) {

        if let marketID = market.id {

            session.subscribe(toMarket: marketID) { replyObject in

                self.marketSubscriptions[marketID] = { print("Notified for \(marketID)") }

                self.session.connection.addObserver(forNotificationNamed: marketChangedNotificationKey, object: self, sel: #selector(SubscriptionNotifier.marketChangeNotification))
            }
        }
    }

    func unsubscribe(fromMarket market: Market) {

        if let marketID = market.id {

            marketSubscriptions[marketID] = nil

            session.unsubscribe(fromMarket: marketID) { replyObject in

                self.session.connection.removeObserver(forNotificationNamed: marketChangedNotificationKey, object: self)
            }
        }
    }

    // MARK: Notifications

    @objc func marketChangeNotification(note: Notification) {

        // Get the market entries contained in the change notification.
        if let result = note.userInfo?["result"] as? [String : Any] {

            if let id = result["market_id"] as? String, let subFunc = marketSubscriptions[id] {

                subFunc()
            }
        }
    }

    @objc func entryChangeNotification(note: Notification) {

        // Get the market entries contained in the change notification.
        if let result = note.userInfo?["result"] as? [AnyHashable : Any], let changes = result["market_entries"] as? [[String : Any]] {

            for change in changes {

                if let id = change["market_entry_id"] as? String, let subFunc = marketSubscriptions[id] {

                    subFunc()
                    //
                    //                    // Find the original market entry that this relates to
                    //                    for (index, marketEntry) in (marketEntries ?? []).enumerated() {
                    //
                    //                        if marketEntry["market_entry_id"] as? String == id {
                    //
                    //                            let applyDeltas: (String) -> Void = { key in
                    //
                    //                                self.marketEntries?[index][key] = self.apply(deltaList: change[key] as? [[String : Any?]?], toMarketEntryBets: marketEntry[key] as? [[String : Any]])
                    //                            }
                    //
                    //                            DispatchQueue.global().async {
                    //
                    //                                applyDeltas(unmatchedForKey)
                    //                                applyDeltas(unmatchedAgainstKey)
                    //
                    //                                let ip = IndexPath(row: index, section: 0)
                    //                                DispatchQueue.main.sync { self.tableView.reloadRows(at: [ip], with: .automatic) }
                    //                            }
                    //                            
                    //                            break
                    //                        }
                    //                    }
                }
            }
        }
    }
}
