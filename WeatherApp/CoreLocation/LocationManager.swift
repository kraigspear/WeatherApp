//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import os.log

typealias RequestLocationResult = (Result<CLLocation, Error>) -> Void

/**
 Protocol to match CLLocationManager as much as possible for testing.

 Access to permissions and the location of this device
 */
protocol LocationManageable: AnyObject {
    var delegate: LocationManagerDelegate? { get set }

    /// Returns a Boolean value indicating whether location services are enabled on the device.
    var locationServicesEnabled: Bool { get }

    /// Returns the app’s authorization status for using location services.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Requests the user’s permission to use location services while the app is in use.
    func requestWhenInUseAuthorization()

    /// Requests the one-time delivery of the user’s current location.
    func requestLocation(_ result: @escaping RequestLocationResult)
    
    /// Is a current search operation taking place
    var isSearchingForLocation: Bool { get }
}

protocol LocationManagerDelegate: AnyObject {
    func authStatusUpdated(to: CLAuthorizationStatus)
}

/**
 Implementation of `LocationManageable`
 Access to permissions and the location of this device
 */
final class LocationManager: NSObject, LocationManageable {
    weak var delegate: LocationManagerDelegate?

    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            delegate?.authStatusUpdated(to: authorizationStatus)
        }
    }

    private let log = LogContext.locationManager

    override init() {
        super.init()
        cllocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        cllocationManager.delegate = self
    }

    /// Wrapped instance
    private let cllocationManager = CLLocationManager()

    // MARK: Requesting Authorization for Location Services

    /// The App's authorization status for using location services
    private var authorizationCurrentValueSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(CLLocationManager.authorizationStatus())

    /// Returns a Boolean value indicating whether location services are enabled on the device.
    var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    /// Requests the user’s permission to use location services while the app is in use.
    func requestWhenInUseAuthorization() {
        os_log("requestWhenInUseAuthorization",
               log: log,
               type: .debug)
        cllocationManager.requestWhenInUseAuthorization()
    }

    // MARK: Requesting Location

    
    private var requestLocationResult: RequestLocationResult?
    public func requestLocation(_ result: @escaping RequestLocationResult) {
        os_log("requestLocation",
               log: log,
               type: .debug)

        assert(requestLocationResult == nil, "Previous requestLocationResult")
        requestLocationResult = result
        cllocationManager.requestLocation()
    }
    
    var isSearchingForLocation: Bool { requestLocationResult != nil }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("authorization changed to %d",
               log: log,
               type: .debug,
               status.rawValue)
        authorizationStatus = status
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        os_log(": %d",
               log: log,
               type: .debug,
               locations.count)

        // We're only processing the first location sent to `didUpdateLocations`
        // Publisher is closed after the first call
        defer {
            assert(requestLocationResult != nil, "Nowhere to send to the result, should not be nil")
            requestLocationResult = nil
        }

        guard let firstLocation = locations.first else {
            assertionFailure("didUpdateLocations called without at least one location?")
            return
        }
        
        requestLocationResult?(Result.success(firstLocation))
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        requestLocationResult?(Result.failure(error))
        requestLocationResult = nil
    }
}
