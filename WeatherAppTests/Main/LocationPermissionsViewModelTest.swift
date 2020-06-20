//
//  LocationPermissionsViewModelTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

@testable import WeatherApp
import XCTest

final class LocationPermissionsViewModelTest: XCTestCase {
    private var settingsOpener: SettingsOpenMock!
    private var locationPermissionsViewModel: LocationPermissionViewModel!

    override func setUpWithError() throws {
        settingsOpener = SettingsOpenMock()
        locationPermissionsViewModel = LocationPermissionViewModel(settingsOpener: settingsOpener)
    }

    func testSettingsAreOpenedWhenOpenSettingsIsCalled() throws {
        XCTAssertEqual(0, settingsOpener.openCalled)
        locationPermissionsViewModel.openSettings()
        XCTAssertEqual(1, settingsOpener.openCalled)
    }
}
