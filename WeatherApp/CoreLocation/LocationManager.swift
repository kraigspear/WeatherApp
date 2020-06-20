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
 Protocol to match CLLocationManager as much as possible.

 It is common to use have a protcol match a framework type, so that
 a wrapper class is not needed.

 In this case since we have some class functions
 we are creating a wrapper.

 Abstracts out `CLLocationManager` for testing
 */
protocol LocationManageable {
    var locationServicesEnabled: Bool { get }

    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var currentLocation: CurrentLocationPublisher { get }

    func requestWhenInUseAuthorization()

    func requestLocation() -> AnyPublisher<CLLocation, Error>
}

/**
 Implementation of `LocationManageable`
 */
final class LocationManager: NSObject, LocationManageable {
    private let log = LogContext.locationManager

    override init() {
        super.init()
        cllocationManager.delegate = self
    }

    private let cllocationManager = CLLocationManager()

    private var currentLocationValueSubject = CurrentValueSubject<CLLocation?, Error>(nil)

    public var currentLocation: CurrentLocationPublisher {
        currentLocationValueSubject.eraseToAnyPublisher()
    }

    private var authorizationCurrentValueSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(CLLocationManager.authorizationStatus())

    public var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationCurrentValueSubject.eraseToAnyPublisher()
    }

    public var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    public func requestWhenInUseAuthorization() {
        os_log("requestWhenInUseAuthorization",
               log: log,
               type: .debug)
        cllocationManager.requestWhenInUseAuthorization()
    }

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

        if let firstLocation = locations.first {
            // We assume that if we're receiving a location then the publisher is active.
            // If not, we could have a logic error.
            assert(requestLocationPublisher != nil, "requestLocationPublisher is nil?")
            requestLocationPublisher?.send(firstLocation)
            requestLocationPublisher?.send(completion: .finished)
            requestLocationPublisher = nil
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        requestLocationPublisher?.send(completion: .failure(error))
    }
}
