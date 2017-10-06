//
//  ServerSession+Bet.swift
//  BetMe
//
//  Created by Rich Henry on 05/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

extension ServerSession {

    func placeBet(forMarketEntryID entryID: String, accountID acID: String, price: Decimal, size: Decimal, back: Bool, completion: @escaping ([String : Any]) -> Void) {

        guard let sID = sessionId else { return }

        let queryObject = makeJSONQueryDict(withMethod: "place_bet", params: ["session_id" : sID, "account_id" : acID, "market_entry_id" : entryID, "viewpoint" : back ? "1" : "-1", "price" : "\(price)", "size" : "\(size)"])

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Place Bet Error") as? [String : Any] { completion(result) }
        }
    }

    func updateBet(forMarketID mkID: String, betID: String, price: Decimal, size: Decimal, keep: Bool, completion: @escaping ([String : Any]) -> Void) {

        guard let sID = sessionId else { return }

        let queryObject = makeJSONQueryDict(withMethod: "update_bet", params: ["session_id" : sID, "bet_id" : betID, "price" : "\(price)", "size" : "\(size)", "keep" : keep ? "1" : "0"])

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Bet Update Error") as? [String : Any] { completion(result) }
        }
    }

    func fetchBettingHistory(forMarketID mkID: String, accountID acID: String, price: Decimal, monthAndYear: Date? = nil, completion: @escaping ([String : Any]) -> Void) {

        guard let sID = sessionId else { return }

        var params = ["session_id" : sID, "account_id" : acID, "market_id" : mkID]

        if let date = monthAndYear {

            let components = NSCalendar.current.dateComponents([.month, .year], from: date)

            if let m = components.month { params["month"] = "\(m)" }
            if let y = components.year  { params["year"] = "\(y)" }
        }

        let queryObject = makeJSONQueryDict(withMethod: "get_betting_history", params: params)

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Bet History Fetch Error") as? [String : Any] { completion(result) }
        }
    }
}
