//
//  RootViewController.swift
//  BetMe
//
//  Created by Rich Henry on 05/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

private let loginUserDefaultsKey = "LoginNameUserDefaultsKey"
private let passUserDefaultsKey = "PasswordUserDefaultsKey"

private let saveLoginAndPassword = false

class RootViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var didLoadBlock: (() -> Void)? = nil

    private let session = BetMeServerSession.sharedInstance

    private var loginAndPassWord: (login: String, pass: String)? {

        get {
            guard let u = UserDefaults.standard.value(forKey: loginUserDefaultsKey) as? String else { return nil }
            guard let p = UserDefaults.standard.value(forKey: passUserDefaultsKey) as? String else { return nil }

            return (u, p)
        }

        set {
            if let u = newValue?.0 { UserDefaults.standard.set(u, forKey: loginUserDefaultsKey) }
            if let p = newValue?.1 { UserDefaults.standard.set(p, forKey: passUserDefaultsKey) }
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        if let loginAndPass = loginAndPassWord {

            if Settings.sharedInstance.autoLogin {

                login(userName: loginAndPass.login, password: loginAndPass.pass, segueName: "autoLogin")

            } else {

                userNameTextField.text = loginAndPass.login
                passwordTextField.text = loginAndPass.pass
            }
        }
        
        didLoadBlock?()
    }

    // MARK: Login / out

    private func login(userName: String, password: String, segueName: String = "login") {

        session.login(username: userName, password: password) { reply in

            if stripResultOrReportError(fromDictionary: reply, fromViewController: self, withTitle: "Login Error") is [String : Any] {

                // Login success, save the login and pass.
                self.loginAndPassWord = (userName, password)

                // Get the default account
                let _ = AccountManager.sharedInstance
                
                // Segue to the app's tabbed viewcontroller.
                self.performSegue(withIdentifier: segueName, sender: self)
            }
        }
    }

    private func logout(andClearSavedCredentials clear: Bool = false) {

        session.logout()

        UserDefaults.standard.set(nil, forKey: loginUserDefaultsKey)
        UserDefaults.standard.set(nil, forKey: passUserDefaultsKey)
        UserDefaults.standard.synchronize()

        userNameTextField.text = nil
        passwordTextField.text = nil
    }

    // MARK: Actions

    @IBAction func loginButtonTapped(_ sender: UIButton) {

        login(userName: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
    }

    @IBAction func passwordTextFieldReturnPressed(_ sender: UITextField) {

        login(userName: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
    }

    @IBAction func userNameTextFieldReturnPressed(_ sender: UITextField) {

        passwordTextField.becomeFirstResponder()
    }

    // MARK: Navigation

    @IBAction func unwindToRoot(sender: UIStoryboardSegue) {

        logout(andClearSavedCredentials: true)
    }
}
