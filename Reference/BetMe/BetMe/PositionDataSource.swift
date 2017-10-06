//
//  PositionDataSource.swift
//  BetMe
//
//  Created by Rich Henry on 04/09/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

class PositionDataSource : SubscriptionDataSource {

    private let mergeQueue = DispatchQueue(label: "me.bet.position_data_source_queue")

    // MARK: Notification

    override func subscriptionChangeNotification(note: Notification) {

        if let result = note.userInfo?["result"] as? [SubsData] {

            mergePositionData(withDeltas: result)
        }
    }

    private func mergePositionData(withDeltas deltas: [SubsData]) {

        for delta in deltas {

            if let marketID = delta["market_id"] as? String {

                var indicesToRefresh = [IndexPath]()

                // Find the original market entry that this relates to…
                sectionLoop: for (sectionIndex, sectionEntry) in self.data.enumerated() {

                    for (entryIndex, entry) in sectionEntry.enumerated() {

                        if let compareID = entry["market_id"] as? String, compareID == marketID {

                            mergeQueue.async {

                                for (key, value) in delta {

                                    if key == "market_entries" {

                                        if let marketEntries = self.data[sectionIndex][entryIndex][key] as? [SubsData] {

                                            self.data[sectionIndex][entryIndex][key] = self.dictMerge(marketEntries, self.dictionaryOfMarketEntries(fromDelta: delta), "market_entry_id")
                                        }

                                    } else {

                                        self.data[sectionIndex][entryIndex][key] = value
                                    }
                                }

                                indicesToRefresh.append(IndexPath(row: entryIndex, section: sectionIndex))
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
