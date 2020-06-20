//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import os.log
import UIKit

final class MainViewModel: ObservableObject {
    private let log = LogContext.mainViewModel

    private let notificationPublisher: NotificationPublishable

    private var cancels = Set<AnyCancellable>()

    // MARK: - Init

    init(locationManager: LocationManageable = LocationManager(),
         notificationPublisher: NotificationPublishable = NotificationPublishers(),
         weatherDataFetcher: WeatherDataFetchable = WeatherDataFetcher()) {
        self.locationManager = locationManager
        self.notificationPublisher = notificationPublisher
        self.weatherDataFetcher = weatherDataFetcher

        notificationPublisher.appWillEnterForeground.sink { [weak self] _ in
            self?.reload()
        }.store(in: &cancels)

        locationManager.authorizationStatus.assign(to: \.authorizationStatus, on: self)
            .store(in: &cancels)
    }

    /**
     Since this App requries knowing the current location
     A embedded view is shown asking for permissions if they
     have not been granted
     */
    @Published var isPermissionViewHidden = false

    private var errorSubject = PassthroughSubject<Error?, Never>()

    public var error: AnyPublisher<Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    /// Verify that all ViewModel state is fresh.
    func reload() {
        os_log("reload",
               log: log,
               type: .debug)

        checkLocationPermissions()
    }

    // MARK: - Weather

    /// Fetches weather data
    private let weatherDataFetcher: WeatherDataFetchable

    // MARK: - Location

    private let locationManager: LocationManageable
    private var authorizationStatus = CLAuthorizationStatus.notDetermined {
        didSet {
            checkLocationPermissions()
        }
    }

    private func checkLocationPermissions() {
        if !locationManager.locationServicesEnabled {
            os_log("Location services turned off on device",
                   log: log,
                   type: .debug)

            isPermissionViewHidden = false
            return // With location permissions not being on there is no need to check App permissions
        }

        isPermissionViewHidden = true

        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        default:
            break
        }
    }

    private var requestLocationCancel: AnyCancellable?
    private func requestLocation() {
        requestLocationCancel = locationManager.requestLocation().sink(receiveCompletion: { [weak self] completed in

            defer { self?.requestLocationCancel = nil }

            switch completed {
            case let .failure(error):
                self?.errorSubject.send(error)
            case .finished:
                break
            }

        }) { [weak self] currentLocation in
            self?.weatherDataFetcher.fetchWeatherForCoordinate(currentLocation.coordinate)
        }
    }
}
