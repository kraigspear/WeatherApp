//
//  MainViewModelTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import XCTest

@testable import WeatherApp

private enum SomeError: Error {
    case error
}

final class MainViewModelTest: XCTestCase {
    private var locationManageableMock: LocationManageableMock!
    private var notificationMock: NotificationPublishableMock!
    private var weatherDataFetchMock: WeatherDataFetchableMock!

    private var mainViewModel: MainViewModel!
    private var observeViewStateChanged: NSKeyValueObservation?

    private let keyPath = \MainViewModel.viewState

    override func setUpWithError() throws {
        locationManageableMock = LocationManageableMock()
        notificationMock = NotificationPublishableMock()
        weatherDataFetchMock = WeatherDataFetchableMock()

        mainViewModel = MainViewModel(locationManager: locationManageableMock,
                                      notificationPublisher: notificationMock,
                                      weatherDataFetcher: weatherDataFetchMock)
    }

    override func tearDown() {
        errorCancel = nil
        observeViewStateChanged = nil
    }

    func testLocationServiceTurnedOffIsShownWhenLocationServicesAreNotOn() {
        locationManageableMock.setupForlocationServicesEnabled(false)
        mainViewModel.reload()
        XCTAssertFalse(mainViewModel.viewState.isPermissionViewHidden)
    }

    func testLocationServiceTurnedOffIsNotShownWhenLocationServicesAreOn() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        mainViewModel.reload()
        XCTAssertTrue(mainViewModel.viewState.isPermissionViewHidden)
    }

    func testLocationServiceTurnedOffIsShownWhenPermissionsDenied() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .denied)
        mainViewModel.reload()
        XCTAssertFalse(mainViewModel.viewState.isPermissionViewHidden)
    }

    func testLocationServiceTurnedOffIsShownWhenPermissionsRestricted() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .restricted)
        mainViewModel.reload()
        XCTAssertFalse(mainViewModel.viewState.isPermissionViewHidden)
    }

    /**
     When the App enters the foreground all state should be checked including
     if the LocationServices view should be shown
     */
    func testLocationServicesEnabledIsCheckedWhenAppEnteresForeground() {
        XCTAssertEqual(0, locationManageableMock.locationServicesEnabledCalled)
        mainViewModel.reload()
        XCTAssertEqual(1, locationManageableMock.locationServicesEnabledCalled)
        notificationMock.sendAppWillEnterForeground()
        XCTAssertEqual(2, locationManageableMock.locationServicesEnabledCalled)
    }

    /**
     This is App is functional without location permissions
     This test, test that when permissions have not been granted
     The user is shown a view that allows then to ask for permissions.
     */
    func testAskForLocationPermissionsIsShownWhenPermissionsAreNotDetermined() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .notDetermined)

        XCTAssertEqual(1, locationManageableMock.requestWhenInUseAuthorizationCalled)

        mainViewModel.reload()

        XCTAssertEqual(2, locationManageableMock.requestWhenInUseAuthorizationCalled)
    }

    func testAskForLocationPermissionsIsNotShownWhenPermissionsAreWhileInUse() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        mainViewModel.reload()

        XCTAssertEqual(0, locationManageableMock.requestWhenInUseAuthorizationCalled)
    }

    func testLocationRequestedWhenLocationPermissionsAreWhenInUse() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        mainViewModel.reload()
        // Verify permissions were not asked for
        XCTAssertEqual(1, locationManageableMock.requestLocationCalled)
    }

    func testLocationNotRequestedWhenLocationPermissionsIsNotDeterminded() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .notDetermined)

        mainViewModel.reload()
        XCTAssertEqual(0, locationManageableMock.requestLocationCalled)
    }

    /**
     1. Permissions not orginally granted
     2. User grants permissions
     3. Request current location
     */
    func testWeatherDataIsRefreshedWhenLocationPermissionsChangesToWhileInUse() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .notDetermined)

        XCTAssertEqual(0, locationManageableMock.requestLocationCalled)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)
        XCTAssertEqual(1, locationManageableMock.requestLocationCalled)
    }

    /**
     1. Location manager provides a location
     2. Weather data is retirved for that location
     3. Weather data is populated
     */
    func testWeatherDataIsRefreshedWhenLocationIsReceived() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        let currentConditions: CurrentConditions = loadModel(from: "CurrentConditions")
        let fetchWeatherResult = FetchWeatherForCoordinateResult.success(currentConditions)
        weatherDataFetchMock.setupForFetchWeatherForCoordinate(result: fetchWeatherResult)

        let lat = 42.9634
        let lng = -85.6681

        let location = CLLocation(latitude: lat, longitude: lng)

        let expectTemperatureSet = expectation(description: "temperatureSet")

        observeViewStateChanged = mainViewModel.observe(keyPath) { viewModel, _ in
            if viewModel.viewState.temperature == "70℉" {
                expectTemperatureSet.fulfill()
            }
        }

        mainViewModel.reload()
        locationManageableMock.requestLocationSuccess(location: location)

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectTemperatureSet], timeout: 1))
    }

    func testErrorIsShownWhenRefreshWeatherFails() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)
        let fetchWeatherResult = FetchWeatherForCoordinateResult.failure(SomeError.error)
        weatherDataFetchMock.setupForFetchWeatherForCoordinate(result: fetchWeatherResult)

        let lat = 42.9634
        let lng = -85.6681

        let location = CLLocation(latitude: lat, longitude: lng)

        let expectError = expectation(description: "error")

        mainViewModel.onError = { _ in
            expectError.fulfill()
        }

        mainViewModel.reload()
        locationManageableMock.requestLocationSuccess(location: location)

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectError], timeout: 1))
    }

    func testErrorIsReceivedWhenRequestLocationFails() {
        enum RequestError: Error {
            case whoops
        }

        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        let expectError = expectation(description: "error")

        mainViewModel.onError = { _ in
            expectError.fulfill()
        }

        mainViewModel.reload()
        locationManageableMock.requestLocationFailed(error: RequestError.whoops)
        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectError], timeout: 1))
    }

    func testForecastButtonIsDisabledWhenDataIsLoading() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        let currentConditions: CurrentConditions = loadModel(from: "CurrentConditions")
        let fetchWeatherResult = FetchWeatherForCoordinateResult.success(currentConditions)
        weatherDataFetchMock.setupForFetchWeatherForCoordinate(result: fetchWeatherResult)

        let lat = 42.9634
        let lng = -85.6681

        let location = CLLocation(latitude: lat, longitude: lng)

        let expectedEnabled = expectation(description: "enabled")

        XCTAssertFalse(mainViewModel.viewState.isForecastButtonEnabled)

        observeViewStateChanged = mainViewModel.observe(keyPath) { viewModel, _ in
            if viewModel.viewState.isForecastButtonEnabled {
                expectedEnabled.fulfill()
            }
        }

        mainViewModel.reload()
        locationManageableMock.requestLocationSuccess(location: location)

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectedEnabled], timeout: 1))
    }
}
