//
//  LocationUtils.swift
//  BetMe
//
//  Created by Rich Henry on 24/04/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import CoreLocation
import LocalAuthentication

internal class UserLocator : NSObject, CLLocationManagerDelegate {

    var currentLocation: CLLocation? = nil

    class var sharedInstance : UserLocator {

        struct Static { static let instance: UserLocator = UserLocator() }

        return Static.instance
    }

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    // MARK: Lifecycle

    override init() {

        super.init()

        if CLLocationManager.locationServicesEnabled() {

            // Set the location manager delegate and start monitoring for significant changes in location.
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()

            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let loc = locations[0]

        geocoder.reverseGeocodeLocation(loc) { placeMark, error in

            print("CLPlacemark = \(String(describing: placeMark)) Error = \(String(describing: error))")
        }

        currentLocation = loc
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("Error = \(String(describing: error))")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        print("Status auth = \(String(describing: status))")
    }
}

internal class UserAuthenticator {

    class var sharedInstance : UserAuthenticator {

        struct Static { static let instance: UserAuthenticator = UserAuthenticator() }

        return Static.instance
    }

    private let authenicationContext = LAContext()

    init() {

        let error: NSErrorPointer = nil

        if authenicationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: error) {

            authenicationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We really want to see those fingers") { reply, error in print("Wow!") }

        } else { print("Error = \(String(describing: error))") }
    }
}
