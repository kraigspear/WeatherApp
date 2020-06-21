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

typealias CurrentLocationPublisher = AnyPublisher<CLLocation?, Error>

/**
 Protocol to match CLLocationManager as much as possible for testing.

 Access to permissions and the location of this device
 */
protocol LocationManageable {
    /// Returns a Boolean value indicating whether location services are enabled on the device.
    var locationServicesEnabled: Bool { get }

    /// Returns the app’s authorization status for using location services.
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }

    /// Requests the user’s permission to use location services while the app is in use.
    func requestWhenInUseAuthorization()

    /// Requests the one-time delivery of the user’s current location.
    func requestLocation() -> AnyPublisher<CLLocation, Error>
}

/**
 Implementation of `LocationManageable`
 Access to permissions and the location of this device
 */
final class LocationManager: NSObject, LocationManageable {
    private let log = LogContext.locationManager

    override init() {
        super.init()
        cllocationManager.delegate = self
    }

    /// Wrapped instance
    private let cllocationManager = CLLocationManager()

    // MARK: Requesting Authorization for Location Services

    /// The App's authorization status for using location services
    private var authorizationCurrentValueSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(CLLocationManager.authorizationStatus())

    /// The App's authorization status for using location services, publisher
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationCurrentValueSubject.eraseToAnyPublisher()
    }

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

    private var requestLocationPublisher: PassthroughSubject<CLLocation, Error>?
    public func requestLocation() -> AnyPublisher<CLLocation, Error> {
        os_log("requestLocation",
               log: log,
               type: .debug)

        requestLocationPublisher = PassthroughSubject<CLLocation, Error>()
        cllocationManager.requestLocation()
        return requestLocationPublisher!.eraseToAnyPublisher()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("authorization changed to %d",
               log: log,
               type: .debug,
               status.rawValue)
        authorizationCurrentValueSubject.value = status
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        os_log("didUpdateLocations count: %d",
               log: log,
               type: .debug,
               locations.count)

        // We're only processing the first location sent to `didUpdateLocations`
        // Publisher is closed after the first call
        defer {
            requestLocationPublisher?.send(completion: .finished)
            requestLocationPublisher = nil
        }

        guard let firstLocation = locations.first else {
            assertionFailure("didUpdateLocations called without at least one location?")
            return
        }

        // We assume that if we're receiving a location then the publisher is active.
        // If not, we could have a logic error.
        assert(requestLocationPublisher != nil, "requestLocationPublisher is nil?")
        requestLocationPublisher?.send(firstLocation)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        requestLocationPublisher?.send(completion: .failure(error))
    }
}
