//
//  ServerConnection.swift
//  BetMe
//
//  Created by Rich Henry on 11/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation
import Starscream

let positionsChangedNotificationKey = "type:positions:notification"
let accountChangedNotificationKey = "type:accounts:notification"
let marketChangedNotificationKey = "type:market:notification"
let entryChangedNotificationKey = "type:market_entry:notification"
let betsChangedNotificationKey = "type:bets:notification"

private extension Dictionary where Key == String {

    var utf8jsonEncodedString: String? {

        if let jData = try? JSONSerialization.data(withJSONObject: self) { return String(data: jData, encoding: .utf8) } else { return nil }
    }
}

private extension String {

    func jsonObject() -> [String : Any]? {

        if let data = self.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] { return json } else { return nil }
    }
}

class ServerConnection {

    public var useBackgroundQueue = false
    public var connected: Bool = false

    typealias SessionReplyBlock = ((_ reply: [String : Any]) -> Void)?

    private var responseHandlers: [String : SessionReplyBlock] = [:]
    private let socket = WebSocket(url: URL(string: UserDefaults.standard.string(forKey: "websocket_url_settings_preference")!)!)
    private let notificationCentre = NotificationCenter()

    // MARK: Lifecycle

    init() {

        responseHandlers[positionsChangedNotificationKey] = { replyObject in self.notificationCentre.post(name: NSNotification.Name(rawValue: positionsChangedNotificationKey), object: self, userInfo: replyObject) }
        responseHandlers[accountChangedNotificationKey] = { replyObject in self.notificationCentre.post(name: NSNotification.Name(rawValue: accountChangedNotificationKey), object: self, userInfo: replyObject) }
        responseHandlers[marketChangedNotificationKey] = { replyObject in self.notificationCentre.post(name: NSNotification.Name(rawValue: marketChangedNotificationKey), object: self, userInfo: replyObject) }
        responseHandlers[entryChangedNotificationKey] = { replyObject in self.notificationCentre.post(name: NSNotification.Name(rawValue: entryChangedNotificationKey), object: self, userInfo: replyObject) }
        responseHandlers[betsChangedNotificationKey] = { replyObject in self.notificationCentre.post(name: NSNotification.Name(rawValue: betsChangedNotificationKey), object: self, userInfo: replyObject) }
    }

    deinit {

        responseHandlers[positionsChangedNotificationKey] = nil
        responseHandlers[accountChangedNotificationKey] = nil
        responseHandlers[marketChangedNotificationKey] = nil
        responseHandlers[entryChangedNotificationKey] = nil
        responseHandlers[betsChangedNotificationKey] = nil

        disconnect()
    }

    // MARK: Connection I/O

    func writeRequest(jsonObject: [String : Any], completion: SessionReplyBlock) {

        // Make sure the supplied object can be converted to a UTF8 string.
        guard let jsonString = jsonObject.utf8jsonEncodedString else { return }

        // Queue the completion lambda with its id string.
        if let id = jsonObject["id"] as? String { responseHandlers[id] = completion }

        self.socket.write(string: jsonString)
    }

    // MARK: Connection Handling

    func connect(withCompletion completion: (() -> Void)? = nil) {

        if useBackgroundQueue { socket.callbackQueue = DispatchQueue(label: "com.easysoft.starscream.betme") }

        socket.onConnect = {

            self.socket.onText = { replyString in

                if let replyObject = replyString.jsonObject() {

                    // Find the completion lambda that matches the id or the type.
                    if let key = replyObject["id"] as? String, let completion = self.responseHandlers[key] {

                        // Call the completion lambda.
                        completion?(replyObject)

                        // Clear the entry.
                        self.responseHandlers[key] = nil

                    } else if let key = replyObject["type"] as? String, let completion = self.responseHandlers["type:\(key):notification"] {

                        // If there is no ID but there is a type, then it's a broadcast message.
                        // These messages are not removed from the queue after handling them.
                        completion?(replyObject)

                    } else { print("Unrecognised reply object = \(replyObject)") }
                }
            }

            self.connected = true

            // This is the completion block that was passed as a parameter.
            completion?()
        }

        socket.connect()
    }
    
    func disconnect(withCompletion completion: (() -> Void)? = nil) {


        socket.onDisconnect = { (error: NSError?) in

            if let err = error { print("Websocket disconnect error: \(err.localizedDescription)") }

            self.connected = false

            completion?()
        }

        socket.disconnect()
    }

    // MARK: Response Handling

    func addObserver(forNotificationNamed name: String, object: Any, sel: Selector) {

        notificationCentre.addObserver(object, selector: sel, name: NSNotification.Name(rawValue: name), object: self)
    }

    func removeObserver(forNotificationNamed name: String, object: Any) {

        notificationCentre.removeObserver(object, name: NSNotification.Name(rawValue: name), object: self)
    }
}
