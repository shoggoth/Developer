//
//  SettingsRootViewController.swift
//  BetMe
//
//  Created by Rich Henry on 13/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

class SettingsRootViewController: UITableViewController {

    @IBOutlet weak var autoLoginSwitch: UISwitch!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set up state.
        autoLoginSwitch.isOn = Settings.sharedInstance.autoLogin

        // Add a tap gesture recogniser that will dismiss the keyboard.
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        dismissKeyboardGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardGesture)
    }

    func endEditing() { self.view.endEditing(false) }

    // MARK: Actions

    @IBAction func autoLoginSwitchValueChanged(_ sender: UISwitch) {

        Settings.sharedInstance.autoLogin = sender.isOn
    }

    // MARK: Tableview Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK - 

class SettingsAccountSelectionViewController : UITableViewController {

    @IBOutlet weak var sterlingBalanceLabel: UILabel!
    @IBOutlet weak var euroBalanceLabel: UILabel!
    @IBOutlet weak var dollarBalanceLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Get accounts
        AccountManager.sharedInstance.fetchAccounts { result in

            self.sterlingBalanceLabel.text = "£" + ((result[0]["balance"] as? String) ?? "0.00")
            self.euroBalanceLabel.text = "€" + ((result[1]["balance"] as? String) ?? "0.00")
            self.dollarBalanceLabel.text = "$" + ((result[2]["balance"] as? String) ?? "0.00")
        }
    }
}

// MARK -

class SettingsThemeSelectionViewController : UITableViewController {
}
