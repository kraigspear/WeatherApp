//
//  LocationManageableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

@testable import WeatherApp

final class LocationManageableMock: LocationManageable {
    var currentLocation: AnyPublisher<CLLocation?, Never>

    private(set) var requestLocationCalled = 0
    func requestLocation() {
        requestLocationCalled += 1
    }

    private var locationServicesEnabledValue = false
    private(set) var locationServicesEnabledCalled = 0
    var locationServicesEnabled: Bool {
        locationServicesEnabledCalled += 1
        return locationServicesEnabledValue
    }

    private var authorizationStatusValue =
        CurrentValueSubject<CLAuthorizationStatus, Never>(CLAuthorizationStatus.notDetermined)

    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusValue.eraseToAnyPublisher()
    }

    private(set) var requestWhenInUseAuthorizationCalled = 0
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled += 1
    }

    private var currentLocationValue = CurrentValueSubject<CLLocation?, Error>(nil)

    var currentLocation: AnyPublisher<CLLocation?, Error> {
        currentLocationValue.eraseToAnyPublisher()
    }

    // MARK: - Setups

    func setupForlocationServicesEnabled(_ value: Bool) {
        locationServicesEnabledValue = value
    }

    func setupForAuthorizationStatus(is authorizationStatus: CLAuthorizationStatus) {
        authorizationStatusValue.value = authorizationStatus
    }

    func updateAuthorizationStatus(to status: CLAuthorizationStatus) {
        authorizationStatusValue.value = status
    }

    func setupForCurrentLocation(_ currentLocation: CLLocation) {
        currentLocationValue.value = currentLocation
    }
}
