//
//  Market.swift
//  BetMe
//
//  Created by Rich Henry on 26/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

// MARK: Market

struct Market {

    var data: [String : Any] = [:]

    var id: String? { get { return (data["market_id"] ?? data["id"]) as? String }}
    var name: String? { get { return data["name"] as? String }}
    var fancyName: String? { get { return data["other_name"] as? String }}
    var title: String? { get { return formattedNameString(dataDictionary: data, mapping: ["%D" : "display_date", "%E" : "event_name", "%M" : "name"]) }}
    var typeID: Int? { get { return Int(data["event_type_id"] as? String ?? "0") }}

    var entries: [[String : Any]]? { get { return data["market_entries"] as? [[String : Any]]}}
}

// MARK: - Market Entry

struct MarketEntry {

    var data: [String : Any] = [:]

    var id: String? { get { return (data["market_entry_id"] ?? data["id"]) as? String }}

    static let unmatchedForKey = "unmatched_for"
    static let unmatchedAgainstKey = "unmatched_against"
    static let sizeKey = "size"
    static let priceKey = "price"

    func price(forMappingKey mapping: (Int, String)) -> Decimal? {

        if let unmatched = (data[mapping.1] as? [[String : Any?]]) {

            let index = mapping.0

            if index < unmatched.count, let priceString = unmatched[index][MarketEntry.priceKey] as? String { return Decimal(string: priceString) }
        }

        return nil
    }

    static func apply(deltaList: [[String : Any?]?]?, toMarketEntryBets bets: [[String : Any]]?) -> [[String : Any]]? {

        guard let deltas = deltaList else { return bets }

        var newBets = bets ?? [[String : Any]]()

        for (index, delta) in deltas.enumerated() where delta != nil {

            if let delta = delta {

                let p = delta[priceKey] as? String
                let s = delta[sizeKey] as? String

                if p == nil && s == nil && index < newBets.count { newBets.remove(at: index) }

                else if let newDict = [priceKey : p, sizeKey : s] as? [String : String] {

                    if index >= newBets.count { newBets.append(newDict) } else { newBets[index] = newDict }
                }

                else {

                    if p != nil { newBets[index][priceKey] = p }
                    if s != nil { newBets[index][sizeKey] = s }
                }
            }
        }
        
        return newBets
    }
}


// MARK: - Market Injectable

protocol MarketInjectable: class {

    var market: Market? { get set }
}
