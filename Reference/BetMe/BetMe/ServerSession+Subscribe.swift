//
//  ServerSession+Subscribe.swift
//  BetMe
//
//  Created by Rich Henry on 06/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

extension ServerSession {

    func subscribe(withParameters p: [String : Any], sendSessionID: Bool = false, completion: @escaping (Any) -> Void) {

        var params = p

        // Add the session ID if needed.
        if sendSessionID {

            if sessionId != nil { params["session_id"] = sessionId } else { reportError(withTitle: "Subscribe Error", message: "No session ID") }
        }

        let queryObject = makeJSONQueryDict(withMethod: "subscribe", params: params)

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Account Sub Error") { completion(result) }
        }
    }

    func unsubscribe(withParameters params: [String : Any], completion: @escaping ([String : Any]) -> Void) {

        let queryObject = makeJSONQueryDict(withMethod: "unsubscribe", params: params)

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if checkAndReportError(fromDictionary: replyObject, withTitle: "Unsubscribe Error") { completion(replyObject) }
        }
    }

    func subscribe(toType type: String, sendSessionID sID: Bool = false, completion: @escaping (Any) -> Void) {

        subscribe(withParameters: ["type" : type], sendSessionID: sID, completion: completion)
    }

    func unsubscribe(fromType type: String, completion: @escaping ([String : Any]) -> Void) {

        unsubscribe(withParameters: ["type" : type], completion: completion)
    }

    func subscribe(toSubscription sub: (type: String, idKey: String, id: String), completion: @escaping (Any) -> Void) {

        subscribe(withParameters: ["type" : sub.type, sub.idKey : sub.id], completion: completion)
    }

    func unsubscribe(fromSubscription sub: (type: String, idKey: String, id: String), completion: @escaping ([String : Any]) -> Void) {

        unsubscribe(withParameters: ["type" : sub.type, sub.idKey : sub.id], completion: completion)
    }
}

// MARK: - Markets

extension ServerSession {

    func subscribe(toMarket mktID: String, completion: @escaping (Any) -> Void) {

        subscribe(toSubscription: ("market", "market_id", mktID), completion: completion)
    }

    func unsubscribe(fromMarket mktID: String, completion: @escaping (Any) -> Void) {

        unsubscribe(fromSubscription: ("market", "market_id", mktID), completion: completion)
    }
}

// MARK: - Market Entries

extension ServerSession {

    func subscribe(toEntry entID: String, completion: @escaping (Any) -> Void) {

        subscribe(toSubscription: ("market_entry", "market_entry_id", entID), completion: completion)
    }

    func unsubscribe(fromEntry entID: String, completion: @escaping (Any) -> Void) {

        unsubscribe(fromSubscription: ("market_entry", "market_entry_id", entID), completion: completion)
    }
}

// MARK: - Bets

extension ServerSession {

    func subscribe(toBet betID: String, completion: @escaping ([String : Any]) -> Void) {

        let queryObject = makeJSONQueryDict(withMethod: "subscribe", params: ["bet_id" : betID, "type" : "market"])

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Bet Subscribe Error") as? [String : Any] { completion(result) }
        }
    }
}

// MARK: - Positions

extension ServerSession {

    func subscribe(toPositionsInAccount actID: String?, withMarketID mktID: String? = nil, withEntryID entID: String? = nil, completion: @escaping ([[String : Any]]) -> Void) {

        // Make sure we're logged in and have a valid session response from the server.
        guard let sID = sessionId else { return }

        // Construct the parameter block for the request.
        var params = ["session_id" : sID, "type" : "positions"]

        if actID != nil { params["account_id"] = actID }
        if mktID != nil { params["market_id"] = mktID }
        if entID != nil { params["market_entry_id"] = entID }

        let queryObject = makeJSONQueryDict(withMethod: "subscribe", params: params)

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Account Sub Error") as? [[String : Any]] { completion(result) }
        }
    }

    func unsubscribe(fromPositionsInAccount actID: String?, withMarketID mktID: String? = nil, withEntryID entID: String? = nil, completion: @escaping ([String : Any]) -> Void) {

        // Construct the parameter block for the request.
        var params = ["type" : "positions"]

        if actID != nil { params["account_id"] = actID }
        if mktID != nil { params["market_id"] = mktID }
        if entID != nil { params["market_entry_id"] = entID }

        let queryObject = makeJSONQueryDict(withMethod: "unsubscribe", params: params)

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if checkAndReportError(fromDictionary: replyObject, withTitle: "Unsubscribe Error") { completion(replyObject) }
        }
    }
}
