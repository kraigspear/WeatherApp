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

    /// Temperature to display in the View
    @Published var temperature = ""

    private var errorSubject = PassthroughSubject<Error?, Never>()

    public var error: AnyPublisher<Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    /// Current weather conditions to display
    private var currentConditions: CurrentConditions? {
        didSet {
            populate(currentConditions: currentConditions)
        }
    }

    /**
     Populate the view from currentConditions

     If currentConditions is nil, then display values are cleard out

     - parameter currentConditions: Conditions value to populate
     */
    private func populate(currentConditions: CurrentConditions?) {
        guard let currentConditions = currentConditions else {
            temperature = ""
            return
        }

        temperature = "\(Int(currentConditions.main.temp))℉"
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
        case .denied, .restricted:
            isPermissionViewHidden = false
        @unknown default:
            fatalError("Handle new authorizationStatus")
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
            self?.updateWeatherAt(coordinate: currentLocation.coordinate)
        }
    }

    private var fetchWeatherForCoordinateCancel: AnyCancellable?
    private func updateWeatherAt(coordinate: CLLocationCoordinate2D) {
        fetchWeatherForCoordinateCancel = weatherDataFetcher.fetchWeatherForCoordinate(coordinate)
            .retry(2)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in

                guard let self = self else { return }

                switch completed {
                case let .failure(error):
                    os_log("Error getting CurrentConditions with error: %{public}s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)
                    self.errorSubject.send(error)
                case .finished:
                    os_log("Success getting current conditions",
                           log: self.log,
                           type: .debug)
                }

            }) { [weak self] currentConditions in
                self?.currentConditions = currentConditions
            }
    }
}
