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
    func requestWhenInUseAuthorization()
    // func requestLocation()
}

/**
 Implementation of `LocationManageable`
 */
final class LocationManager: NSObject, LocationManageable {
    private let cllocationManager = CLLocationManager()

    private var authorizationCurrentValueSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(CLLocationManager.authorizationStatus())

    public var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationCurrentValueSubject.eraseToAnyPublisher()
    }

    public var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    public func requestWhenInUseAuthorization() {
        cllocationManager.requestWhenInUseAuthorization()
    }
}