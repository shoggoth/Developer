//
//  LocalNotification.swift
//  BetMe
//
//  Created by Rich Henry on 18/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotifier : NSObject, UNUserNotificationCenterDelegate {

    private let nc = UNUserNotificationCenter.current()

    override init() {

        super.init()

        // It is important to set the delegate before your app finishes launching.
        // So it is probably best to initialise the notifier along with the delegate.
        nc.delegate = self

        refreshNotificationPermissions()
    }

    func refreshNotificationPermissions() {

        nc.getNotificationSettings { settings in

            switch settings.authorizationStatus {

            case .notDetermined:
                self.askForAuthorisation(options: [.alert, .sound])

            case .denied: break

            case .authorized: break
            }
        }
    }

    func askForAuthorisation(options: UNAuthorizationOptions) {

        nc.requestAuthorization(options: options) { granted, error in
        }
    }

    public func sendNotification() {

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Buy some onions"
        content.sound = UNNotificationSound.default()

        // Create trigger conditions
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 6, repeats: false)

        // Schedule the notification
        let identifier = "DemoNotification"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        nc.add(request) { error in if let err = error { print("Error in testConnect : \(err.localizedDescription)") }}
    }

    // MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //print("Presenter will present")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        print("Presenter got response")
    }
}
