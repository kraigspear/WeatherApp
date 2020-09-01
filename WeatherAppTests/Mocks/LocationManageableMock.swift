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
    weak var delegate: LocationManagerDelegate?

    var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            delegate?.authStatusUpdated(to: authorizationStatus)
        }
    }

    private(set) var requestLocationCalled = 0

    private var requestLocationPassthroughSubject = PassthroughSubject<CLLocation, Error>()

    func requestLocationSuccess(location: CLLocation) {
        requestLocationPassthroughSubject.send(location)
        requestLocationPassthroughSubject.send(completion: .finished)
    }

    func requestLocationFailed(error: Error) {
        requestLocationPassthroughSubject.send(completion: .failure(error))
    }

    func requestLocation() -> AnyPublisher<CLLocation, Error> {
        requestLocationCalled += 1
        return requestLocationPassthroughSubject.eraseToAnyPublisher()
    }

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
