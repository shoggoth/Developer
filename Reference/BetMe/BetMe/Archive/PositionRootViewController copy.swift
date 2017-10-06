//
//  PositionRootViewController.swift
//  BetMe
//
//  Created by Rich Henry on 24/04/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

private let tempKVKeyValue = "BetMeDemoCloudKey"

class PositionRootViewController : UIViewController {

    @IBOutlet var sceneDockView: UIView!

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cloudTextView: UITextView!
    @IBOutlet weak var marketTextField: UITextField!

    private let session = BetMeServerSession.sharedInstance
    private let subNotifier = SubscriptionNotifier()

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // session.connect()
        setupKVStore()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        //view.addSubview(sceneDockView)
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {

        print("SessionID = \(String(describing: session.sessionId))")
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {

        performSegue(withIdentifier: "unwindToRoot", sender: self)
    }

    @IBAction func fetchUserInfoButtonPressed(_ sender: UIButton) {

        session.userInfo()
        session.loginHistory()
        session.ping()
        session.transactions(forAccountID: "15034")
        session.keepAlive()
        session.setUserInfo()
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {

        keyStore?.set(cloudTextView.text, forKey: tempKVKeyValue)
        keyStore?.synchronize()
    }

    @IBAction func subscribeButtonPressed(_ sender: UIButton) {

        guard let marketID = marketTextField.text else { return }

        subNotifier.subscribe(toMarket: Market(data: ["id" : marketID]))
    }

    @IBAction func unsubscribeButtonPressed(_ sender: UIButton) {

        guard let marketID = marketTextField.text else { return }

        subNotifier.unsubscribe(fromMarket: Market(data: ["id" : marketID]))
    }
    
    func note(note: Notification) {

        print("\(self) received notification: \(String(describing: note.userInfo))")
    }

    // MARK: iCloud KV

    private lazy var keyStore: NSUbiquitousKeyValueStore? = { NSUbiquitousKeyValueStore() }()

    func setupKVStore() {

        let storedString = keyStore?.string(forKey: tempKVKeyValue)

        if let stringValue = storedString { cloudTextView.text = stringValue }

        NotificationCenter.default.addObserver(self, selector: #selector(PositionRootViewController.ubiquitousKeyValueStoreDidChange), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: keyStore)
    }

    func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {

        cloudTextView.text = keyStore?.string(forKey: tempKVKeyValue)
    }

    // MARK: Temp

    @IBAction func unwindToRootPosition(sender: UIStoryboardSegue) {

        // TODO: Remove this.
        
        let sourceViewController = sender.source

        print("Unwound from \(sourceViewController)")
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier != "unwindToRoot" {

            (segue.destination as? MarketInjectable)?.market = Market(data: ["market_id" : marketTextField.text ?? "0"])
        }
    }
}
