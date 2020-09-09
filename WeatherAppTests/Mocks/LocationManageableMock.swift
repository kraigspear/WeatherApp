//
//  LocationManageableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import Foundation

@testable import WeatherApp

final class LocationManageableMock: LocationManageable {
    weak var delegate: LocationManagerDelegate?

    var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            delegate?.authStatusUpdated(to: authorizationStatus)
        }
    }

    private(set) var requestLocationCalled = 0

    func requestLocationSuccess(location: CLLocation) {
        requestLocationResult!(.success(location))
        requestLocationResult = nil
    }

    func requestLocationFailed(error: Error) {
        requestLocationResult!(.failure(error))
        requestLocationResult = nil
    }

    private var requestLocationResult: RequestLocationResult?
    func requestLocation(_ result: @escaping RequestLocationResult) {
        requestLocationCalled += 1
        requestLocationResult = result
    }

    var isSearchingForLocation: Bool { requestLocationResult != nil }

    private var locationServicesEnabledValue = false
    private(set) var locationServicesEnabledCalled = 0
    var locationServicesEnabled: Bool {
        locationServicesEnabledCalled += 1
        return locationServicesEnabledValue
    }

    private(set) var requestWhenInUseAuthorizationCalled = 0
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled += 1
    }

    // MARK: - Setups

    func setupForlocationServicesEnabled(_ value: Bool) {
        locationServicesEnabledValue = value
    }

    func setupForAuthorizationStatus(is authorizationStatus: CLAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
    }

    func updateAuthorizationStatus(to status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}
