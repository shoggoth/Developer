//
//  Account.swift
//  BetMe
//
//  Created by Rich Henry on 07/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

struct Account {

    var accountID: String
}

class AccountManager {

    class var sharedInstance : AccountManager {

        struct Static { static let instance: AccountManager = AccountManager() }

        return Static.instance
    }

    var defaultAccount: Account?

    private let session = BetMeServerSession.sharedInstance

    init() {

        session.fetchAccountDetails { result in

            self.subscribe()

            if let accountID = result.first?["account_id"] as? String {

                self.defaultAccount = Account(accountID: accountID)
            }
        }
    }

    func fetchAccounts(completion: @escaping (([[String : Any]]) -> Void)) {

        session.fetchAccountDetails { result in completion(result) }
    }

    // MARK: Un/Subscribe To Changes

    private func subscribe() {

        // Subscribe to change notifications
        session.subscribe(toType: "accounts", sendSessionID: true) { result in

            if let result = result as? [[String : Any]] {

                for account in result {

                    // print("Account = \(account)")
                }

                // Subscribe to changes in the account
                self.session.connection.addObserver(forNotificationNamed: accountChangedNotificationKey, object: self, sel: #selector(self.accountChangeNotification))
            }
        }
    }

    private func unsubscribe() {

        if let accountID = AccountManager.sharedInstance.defaultAccount?.accountID {

            // Unsubscribe from notifications
            session.unsubscribe(fromPositionsInAccount: accountID) { _ in
                
                self.session.connection.removeObserver(forNotificationNamed: accountChangedNotificationKey, object: self)
            }
        }
    }

    // MARK: Notification

    @objc func accountChangeNotification(note: Notification) {

        if let result = note.userInfo?["result"] as? [[String : Any]] {

            for account in result {

                // print("Account (notification) = \(account)")
            }
        }
    }
}
