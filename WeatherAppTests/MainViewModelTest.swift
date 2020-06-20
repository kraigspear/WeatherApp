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
    private var mainViewModel: MainViewModel!
    
    override func setUpWithError() throws {
        locationManageableMock = LocationManageableMock()
        mainViewModel = MainViewModel(locationManager: locationManageableMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
     This is App is functional without location permissions
     This test, test that when permissions have not been granted
     The user is shown a view that allows then to ask for permissions.
     */
    func testAskForLocationPermissionsIsShownWhenPermissionsAreNotDetermined() throws {
        
        
        
    }


}
