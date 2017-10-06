//
//  Settings.swift
//  BetMe
//
//  Created by Rich Henry on 13/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

class Settings {

    class var sharedInstance : Settings {

        struct Static { static let instance: Settings = Settings() }

        return Static.instance
    }

    private let autoLoginDefaultsKey = "AutoLoginUserDefaultsKey"

    var autoLogin: Bool {

        get { return UserDefaults.standard.value(forKey: autoLoginDefaultsKey) as? Bool ?? false }

        set {
            UserDefaults.standard.set(newValue, forKey: autoLoginDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }
}
