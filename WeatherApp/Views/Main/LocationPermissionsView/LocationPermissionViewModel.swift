//
//  LocationPermissionViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

/// ViewModel for LocationPermissions
/// LocationPermission gives an explamation on why location services are needed
/// and allows opening up settings to grant these permssions.
final class LocationPermissionViewModel {
    /// Open settings
    private let settingsOpener: SettingsOpening

    /**
     Initialize with dependencies
     - parameter settingsOpener: Allows opening up settings
     */
    init(settingsOpener: SettingsOpening = SettingsOpener()) {
        self.settingsOpener = settingsOpener
    }

    /// Open Settings
    func openSettings() {
        settingsOpener.open()
    }
}
