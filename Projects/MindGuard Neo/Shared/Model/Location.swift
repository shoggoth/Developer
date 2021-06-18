//
//  Location.swift
//  MindGuard Neo
//
//  Created by Richard Henry on 16/06/2021.
//

import CoreLocation

class LocationModel: NSObject, ObservableObject {
    
    @Published var location: CLLocationCoordinate2D? = nil
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()

    override init() {
        
        super.init()
        
        init_mods()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    public func requestAuthorisation(always: Bool = false) {
        
        if always {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.authorisationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let loc = locations.last else { return }
        
        self.location = loc.coordinate
    }
}
