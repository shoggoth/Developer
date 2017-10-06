//
//  ServerSession+Account.swift
//  BetMe
//
//  Created by Rich Henry on 09/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

extension ServerSession {

    func fetchAccountDetails(completion: @escaping ([[String : Any]]) -> Void) {

        guard let sID = sessionId else { return }

        let queryObject = makeJSONQueryDict(withMethod: "accounts", params: ["session_id" : sID])

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Account error") as? [[String : Any]] { completion(result) }
        }
    }
}
