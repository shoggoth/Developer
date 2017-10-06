//
//  ServerSession+Market.swift
//  BetMe
//
//  Created by Rich Henry on 31/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

extension ServerSession {

    func getMarket(forMarketID mkID: String, completion: @escaping ([String : Any]) -> Void) {

        let queryObject = makeJSONQueryDict(withMethod: "market", params: ["market_id" : mkID])

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Get Market Error") as? [String : Any] { completion(result) }
        }
    }
}
