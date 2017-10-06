//
//  ServerSession+Group.swift
//  BetMe
//
//  Created by Rich Henry on 11/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

extension ServerSession {

    func getGroupPathChildren(forGroupPathID gpID: String, completion: @escaping ([String : Any]) -> Void) {

        let queryObject = makeJSONQueryDict(withMethod: "group_path", params: ["group_path_id" : gpID])

        connection.writeRequest(jsonObject: queryObject) { replyObject in

            if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Group Fetch Error") as? [String : Any] { completion(result) }
        }
    }
}
