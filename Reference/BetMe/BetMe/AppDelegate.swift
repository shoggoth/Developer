//
//  AppDelegate.swift
//  BetMe
//
//  Created by Rich Henry on 13/04/2017.
//  Copyright © 2017 Rich Henry. All rights reserved.
//

import UIKit
import CoreDataStack

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let notifier = LocalNotifier()
    static let coreDataStack = CoreDataStack(modelName: "Model")

    override init() {

        super.init()

        // Set user defaults initial values.
        loadInitialDefaults()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        // Inject dependencies
        (window?.rootViewController as? RootViewController)?.didLoadBlock = nil

        // Set the application's appearance
        setupApplicationAppearance()

        // Temp
        AppDelegate.notifier.sendNotification()

        return true
    }

//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//
//        let queryComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
//
//        print("Opened from URL.\nScheme = \(url.scheme)\nPath = \(url.path)\nQuery = \(url.query)\nQueryC = \(queryComponents?.queryItems)\nHost = \(url.host)\nOptions = \(options)")
//
//        return true
//    }
}

private extension AppDelegate {

    func setupApplicationAppearance() {
        
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
    }
}

private extension AppDelegate {

    func loadInitialDefaults() {

        let userDefaults = UserDefaults.standard

        if let defaultsPListPath = Bundle.main.path(forResource: "InitialDefaults", ofType: "plist") {

            if let defaultsDict = NSDictionary(contentsOfFile: defaultsPListPath) as? [String : Any] {

                userDefaults.register(defaults: defaultsDict)
                userDefaults.synchronize()
            }
        }
    }
}
