//
//  ServerConnection.swift
//  BetMe
//
//  Created by Rich Henry on 11/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

// http://betdevel.easysoft.local/~jason/BET/BET/Service/User.html

class ServerSession {

    var sessionId: String? = nil
    var connection: ServerConnection

    // MARK: Lifecycle

    init() {

        connection = ServerConnection()

        connection.connect()
    }

    // MARK: Account Services

    func login(username: String, password: String, closeActiveSessions: Bool = false, completion: (([String : Any]) -> Void)? = nil) {

        let loginParams = ["username" : username, "password" : password, "close_active_sessions" : closeActiveSessions ? "1" : "0"]
        let loginObject = makeJSONQueryDict(withMethod: "login", params: loginParams)

        connection.writeRequest(jsonObject: loginObject) { replyObject in

            if let result = replyObject["result"] as? [String : String], let s = result["session_id"] {

                self.sessionId = s
            }

            completion?(replyObject)
        }
    }

    func logout(cancelBets: Bool = false, completion: (([String : Any]) -> Void)? = nil) {

        if let sID = sessionId {

            let logoutObject = makeJSONQueryDict(withMethod: "logout", params: ["session_id" : sID, "cancel_bets" : cancelBets ? "1" : "0"])

            connection.writeRequest(jsonObject: logoutObject) { replyObject in

                if let result = stripResultOrReportError(fromDictionary: replyObject, withTitle: "Logout Error") as? [String : Any] { completion?(result) }

                self.sessionId = nil
            }
        }
    }

    func userInfo() {

        if let sID = sessionId {

            let userInfoGetObject = makeJSONQueryDict(withMethod: "get_profile", params: ["session_id" : sID])

            connection.writeRequest(jsonObject: userInfoGetObject) { replyObject in print("profile get = \(replyObject)") }
        }
    }

    func setUserInfo() {

        if let sID = sessionId {

            let userInfoSetObject = makeJSONQueryDict(withMethod: "update_profile", params: ["session_id" : sID, "address_6" : "Nova Petrovsk"])

            connection.writeRequest(jsonObject: userInfoSetObject) { replyObject in print("profile set = \(replyObject)") }
        }
    }

    func loginHistory() {

        if let sID = sessionId {

            let loginHistoryGetObject = makeJSONQueryDict(withMethod: "get_login_history", params: ["session_id" : sID])

            connection.writeRequest(jsonObject: loginHistoryGetObject) { replyObject in print("login history = \(replyObject)") }
        }
    }

    func transactions(forAccountID accountID: String) {

        if let sID = sessionId {

            let profileGetObject = makeJSONQueryDict(withMethod: "get_transactions", params: ["session_id" : sID, "account_id" : accountID])

            connection.writeRequest(jsonObject: profileGetObject) { replyObject in print("transactions = \(replyObject)") }
        }
    }

    private static var pingSequenceNumber = 0

    func ping() {

        if let sID = sessionId {

            let pingObject = makeJSONQueryDict(withMethod: "ping", params: ["session_id" : sID], id: "PING \(ServerSession.pingSequenceNumber)")

            ServerSession.pingSequenceNumber += 1

            connection.writeRequest(jsonObject: pingObject) { replyObject in print("ping = \(replyObject)") }
        }
    }

    func keepAlive() {

        if let sID = sessionId {

            let keepAliveObject = makeJSONQueryDict(withMethod: "send_keep_alive", params: ["session_id" : sID])

            connection.writeRequest(jsonObject: keepAliveObject) { replyObject in print("keepAlive = \(replyObject)") }
        }
    }
}

// MARK: JSON Utils

func makeJSONQueryDict(withMethod method: String, params: [String: Any]? = nil, id: String = UUID().uuidString, rpcVersion: String = "2.0") -> [String : Any] {
    
    var jsonObject: [String : Any] = ["method" : method, "id" : id, "jsonrpc" : rpcVersion]
    
    if params != nil { jsonObject["params"] = params }
    
    return jsonObject
}
