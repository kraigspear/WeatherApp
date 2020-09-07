//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import os.log
import UIKit

@objc class MainViewModelViewState: NSObject {
    var isPermissionViewHidden = false
    var temperature = ""
    var locationName = ""
    var isBusy = false
    var isForecastButtonEnabled = false
}

/// Provides View Logic for the MainViewModel and child ViewControllers
@objc final class MainViewModel: NSObject {
    private let log = LogContext.mainViewModel

    var onError: ((Error) -> Void)?

    // MARK: - Init

    /**
     Initialize a new `MainViewModel` with its dependencies
     - parameter locationManager: Access to the device locatino
     - parameter notificationPublisher: Notfication of the App coming to the Foreground
     - parameter weatherDataFetcher: Fetches weather data
     */
    init(locationManager: LocationManageable = LocationManager(),
         notificationPublisher: NotificationPublishable = NotificationPublishers(),
         weatherDataFetcher: WeatherDataFetchable = WeatherDataFetcher()) {
        self.locationManager = locationManager
        self.notificationPublisher = notificationPublisher
        self.weatherDataFetcher = weatherDataFetcher

        super.init()

        notificationPublisher.appEnteredForeground = { [weak self] in
            self?.reload()
        }

        assert(locationManager.delegate == nil, "Already has delegate?")
        locationManager.delegate = self
    }

    // MARK: - Notifications

    /// Notfication of the App coming to the Foreground
    private let notificationPublisher: NotificationPublishable

    // MARK: - View Properties

    @objc private(set) dynamic var viewState = MainViewModelViewState()

    // MARK: - Weather

    /// Fetches weather data
    private let weatherDataFetcher: WeatherDataFetchable

    /// Current weather conditions to display
    private var currentConditions: CurrentConditions? {
        didSet {
            if let currentConditions = currentConditions {
                populate(currentConditions: currentConditions)
            }
        }
    }

    /**
     Populate the view from currentConditions

     - parameter currentConditions: Conditions value to populate
     */
    private func populate(currentConditions: CurrentConditions) {
        let viewState = self.viewState
        viewState.temperature = "\(Int(currentConditions.main.temperature))℉"
        viewState.locationName = currentConditions.locationName
        self.viewState = viewState
    }

    // MARK: - Location

    /// Coordinate of the location that has been loaded
    private(set) var loadedCoordinate: CLLocationCoordinate2D? {
        didSet {
            viewState.isForecastButtonEnabled = loadedCoordinate != nil
        }
    }

    /**
     Access to the device location, permissions.
     Weather data is shown for the current location.
     */
    private let locationManager: LocationManageable

    private func requestLocation() {
        os_log("requestLocation",
               log: log,
               type: .debug)

        // Avoid searhing when another operation is taking place
        guard !locationManager.isSearchingForLocation else {
            os_log("Another search operation is taking place",
                   log: log,
                   type: .debug)
            return
        }

        viewState.isBusy = true

        locationManager.requestLocation { [weak self] result in

            assert(Thread.isMainThread)

            guard let self = self else { return }

            self.viewState.isBusy = false

            switch result {
            case let .success(location):

                os_log("requestLocation completed successfully",
                       log: self.log,
                       type: .debug)

                self.updateWeatherAt(coordinate: location.coordinate)
            case let .failure(error):
                self.onError?(error)
                os_log("requestLocation completed with error: %s",
                       log: self.log,
                       type: .debug,
                       error.localizedDescription)
            }
        }
    }

    // MARK: - Loading Data

    func reload() {
        os_log("checkLocationPermissions",
               log: log,
               type: .debug)

        if !locationManager.locationServicesEnabled {
            os_log("Location services turned off on device",
                   log: log,
                   type: .debug)

            viewState.isPermissionViewHidden = false
            return // With location permissions not being on there is no need to check App permissions
        }

        viewState.isPermissionViewHidden = true

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:

            os_log("Permissions authorizedWhenInUse or authorizedAlways, requesting location",
                   log: log,
                   type: .debug)

            requestLocation()
        case .denied, .restricted:
            os_log("Location permissions denied or restricted, showing permissions view",
                   log: log,
                   type: .debug)
            viewState.isPermissionViewHidden = false
        @unknown default:
            fatalError("Handle new authorizationStatus")
        }
    }

    private func updateWeatherAt(coordinate: CLLocationCoordinate2D) {
        os_log("Fetching latest current conditions",
               log: log,
               type: .debug)

        viewState.isBusy = true
        loadedCoordinate = nil

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.weatherDataFetcher.fetchCurrentConditionsForCoordinate(coordinate) { result in
                DispatchQueue.main.async {
                    self.viewState.isBusy = false
                    switch result {
                    case let .success(currentConditions):
                        os_log("Success getting current conditions",
                               log: self.log,
                               type: .debug)
                        self.loadedCoordinate = coordinate
                        self.currentConditions = currentConditions
                    case let .failure(error):
                        os_log("Error getting CurrentConditions with error: %{public}s",
                               log: self.log,
                               type: .error,
                               error.localizedDescription)
                        self.onError?(error)
                    }
                }
            }
        }
    }
}

extension MainViewModel: LocationManagerDelegate {
    func authStatusUpdated(to status: CLAuthorizationStatus) {
        os_log("Auth status changed reloading",
               log: log,
               type: .debug,
               status.rawValue)
        reload()
    }
}
