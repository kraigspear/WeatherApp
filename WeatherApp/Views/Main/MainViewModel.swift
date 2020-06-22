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

/// Provides View Logic for the MainViewModel and child ViewControllers
final class MainViewModel: ObservableObject {
    private let log = LogContext.mainViewModel

    /// Cancels for any Publishers that are to active for the lifecycle of the ViewModel
    private var cancels = Set<AnyCancellable>()

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

        notificationPublisher.appWillEnterForeground.sink { [weak self] _ in
            self?.reload()
        }.store(in: &cancels)

        locationManager.authorizationStatus.assign(to: \.authorizationStatus, on: self)
            .store(in: &cancels)
    }

    // MARK: - Notifications

    /// Notfication of the App coming to the Foreground
    private let notificationPublisher: NotificationPublishable

    // MARK: - View Properties

    /**
     Since this App requries knowing the current location
     A embedded view is shown asking for permissions if they
     have not been granted
     */
    @Published var isPermissionViewHidden = false
    /// Temperature to display in the View
    @Published var temperature = ""
    /// The name of the location for the conditions being displayed
    @Published var locationName = ""
    /// Should the visual state showing "busy" be shown
    @Published var isBusy = false
    /// Bool that indicates that if the forecast button should be enabled
    @Published var isForecastButtonEnabled = false

    // MARK: - Error Handeling

    /// PassthroughSubject for errors that should be shown on the view
    private var errorSubject = PassthroughSubject<Error?, Never>()

    /// Errors that should be shown on the view
    public var error: AnyPublisher<Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }

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
        temperature = "\(Int(currentConditions.main.temperature))℉"
        locationName = currentConditions.locationName
    }

    // MARK: - Location

    /// Coordinate of the location that has been loaded
    private(set) var loadedCoordinate: CLLocationCoordinate2D? {
        didSet {
            isForecastButtonEnabled = loadedCoordinate != nil
        }
    }

    /**
     Access to the device location, permissions.
     Weather data is shown for the current location.
     */
    private let locationManager: LocationManageable
    private var authorizationStatus = CLAuthorizationStatus.notDetermined {
        didSet {
            os_log("authorizationStatus set, checkLocationPermissions",
                   log: log,
                   type: .debug)
            reload()
        }
    }

    private var requestLocationCancel: AnyCancellable?
    private func requestLocation() {
        os_log("requestLocation",
               log: log,
               type: .debug)

        precondition(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways, "Invalid authorization status")

        if requestLocationCancel != nil {
            // There are various events that might trigger looking for the location including
            // 1. Forgound
            // 2. Permission changes
            // 3. Startup

            // Calling locationManager.requestLocation will cancel if one is inflight, however
            // it's more efficiant to ignore additinal request if one is active

            os_log("Active requestLocation, skipping",
                   log: log,
                   type: .debug)

            return
        }

        isBusy = true

        requestLocationCancel = locationManager.requestLocation().sink(receiveCompletion: { [weak self] completed in

            guard let self = self else { return }

            self.isBusy = false

            defer { self.requestLocationCancel = nil }

            switch completed {
            case let .failure(error):

                os_log("requestLocation completed with error: %s",
                       log: self.log,
                       type: .debug,
                       error.localizedDescription)

                self.errorSubject.send(error)
            case .finished:
                os_log("requestLocation completed successfully",
                       log: self.log,
                       type: .debug)
            }

        }) { [weak self] currentLocation in
            guard let self = self else { return }

            os_log("current location retrived: lat: %f lng: %f",
                   log: self.log,
                   type: .debug,
                   currentLocation.coordinate.latitude,
                   currentLocation.coordinate.longitude)

            self.updateWeatherAt(coordinate: currentLocation.coordinate)
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

            isPermissionViewHidden = false
            return // With location permissions not being on there is no need to check App permissions
        }

        isPermissionViewHidden = true

        switch authorizationStatus {
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
            isPermissionViewHidden = false
        @unknown default:
            fatalError("Handle new authorizationStatus")
        }
    }

    private var fetchWeatherForCoordinateCancel: AnyCancellable?
    private func updateWeatherAt(coordinate: CLLocationCoordinate2D) {
        os_log("Fetching latest current conditions",
               log: log,
               type: .debug)

        isBusy = true
        loadedCoordinate = nil

        fetchWeatherForCoordinateCancel = weatherDataFetcher.fetchCurrentConditionsForCoordinate(coordinate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in

                guard let self = self else { return }

                self.isBusy = false

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
                    self.loadedCoordinate = coordinate
                }

            }) { [weak self] currentConditions in
                self?.currentConditions = currentConditions
            }
    }
}
