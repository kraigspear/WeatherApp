//
//  MainViewModelTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import XCTest
@testable import WeatherApp

final class MainViewModelTest: XCTestCase {

    private var locationManageableMock: LocationManageableMock!
    private var notificationMock: NotificationPublishableMock!
    
    private var mainViewModel: MainViewModel!
    
    override func setUpWithError() throws {
        locationManageableMock = LocationManageableMock()
        notificationMock = NotificationPublishableMock()
        
        mainViewModel = MainViewModel(locationManager: locationManageableMock,
                                      notificationPublisher: notificationMock)
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
    func testAskForLocationPermissionsIsShownWhenPermissionsAreNotDetermined() throws {
        
        
        
    }


}
