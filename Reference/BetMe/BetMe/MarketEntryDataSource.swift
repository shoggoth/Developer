//
//  MarketEntryDataSource.swift
//  BetMe
//
//  Created by Rich Henry on 04/09/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

class MarketEntryDataSource : SubscriptionDataSource {

    private let mergeQueue = DispatchQueue(label: "me.market_entry.bet_data_source_queue")

    // MARK: Notification

    override func subscriptionChangeNotification(note: Notification) {

        if let result = note.userInfo?["result"] as? [SubsData] {

            mergeMarketEntryData(withDeltas: result)
        }
    }

    private func mergeMarketEntryData(withDeltas deltas: [SubsData]) {

        // Get the market entries contained in the change notification.
        for delta in deltas {

            if let changes = delta["market_entries"] as? [SubsData] {

                var indicesToRefresh = [IndexPath]()

                for change in changes {

                    if let id = change["market_entry_id"] as? String {

                        // Find the original market entry that this relates to
                        for (index, marketEntry) in data[0].enumerated() {

                            if marketEntry["market_entry_id"] as? String == id {

                                let applyDeltas: (String) -> Void = { key in

                                    self.data[0][index][key] = MarketEntry.apply(deltaList: change[key] as? [[String : Any?]?], toMarketEntryBets: marketEntry[key] as? [[String : Any]])
                                }

                                mergeQueue.async {

                                    applyDeltas(MarketEntry.unmatchedForKey)
                                    applyDeltas(MarketEntry.unmatchedAgainstKey)

                                    indicesToRefresh.append(IndexPath(row: index, section: 0))
                                }

                                break
                            }
                        }
                    }
                }

                // Queue a refresh of the table / collection cells that have changed.
                mergeQueue.async {
                    
                    DispatchQueue.main.sync {
                        
                        self.tableView?.reloadRows(at: indicesToRefresh, with: .top)
                        self.collectionView?.reloadItems(at: indicesToRefresh)
                    }
                }
            }
        }
    }
}
