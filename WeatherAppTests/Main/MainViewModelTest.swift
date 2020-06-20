//
//  MainViewModelTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

@testable import WeatherApp
import XCTest

final class MainViewModelTest: XCTestCase {
    private var locationManageableMock: LocationManageableMock!
    private var notificationMock: NotificationPublishableMock!
    private var weatherDataFetchMock: WeatherDataFetchableMock!

    private var mainViewModel: MainViewModel!

    override func setUpWithError() throws {
        locationManageableMock = LocationManageableMock()
        notificationMock = NotificationPublishableMock()
        weatherDataFetchMock = WeatherDataFetchableMock()

        mainViewModel = MainViewModel(locationManager: locationManageableMock,
                                      notificationPublisher: notificationMock,
                                      weatherDataFetcher: weatherDataFetchMock)
    }

    func testLocationServiceTurnedOffIsShownWhenLocationServicesAreNotOn() {
        locationManageableMock.setupForlocationServicesEnabled(false)
        mainViewModel.reload()
        XCTAssertFalse(mainViewModel.isPermissionViewHidden)
    }

    func testLocationServiceTurnedOffIsNotShownWhenLocationServicesAreOn() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        mainViewModel.reload()
        XCTAssertTrue(mainViewModel.isPermissionViewHidden)
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

        XCTAssertEqual(0, locationManageableMock.requestWhenInUseAuthorizationCalled)

        mainViewModel.reload()

        XCTAssertEqual(1, locationManageableMock.requestWhenInUseAuthorizationCalled)
    }

    func testAskForLocationPermissionsIsNotShownWhenPermissionsAreWhileInUse() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        mainViewModel.reload()

        XCTAssertEqual(0, locationManageableMock.requestWhenInUseAuthorizationCalled)
    }

    func testWeatherDataIsRefreshedWhenLocationPermissionsAreWhenInUse() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .authorizedWhenInUse)

        mainViewModel.reload()
        // Verify permissions were not asked for
        XCTAssertEqual(1, weatherDataFetchMock.fetchCalled)
    }

    func testWeatherDataIsNotRefreshedWhenLocationPermissionsIsNotDeterminded() {
        locationManageableMock.setupForlocationServicesEnabled(true)
        locationManageableMock.setupForAuthorizationStatus(is: .notDetermined)

        mainViewModel.reload()
        // Verify permissions were not asked for
        XCTAssertEqual(0, weatherDataFetchMock.fetchCalled)
    }
}
