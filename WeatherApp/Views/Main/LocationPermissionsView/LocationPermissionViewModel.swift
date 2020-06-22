//
//  LocationPermissionViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

final class LocationPermissionViewModel {
    private let settingsOpener: SettingsOpening

    init(settingsOpener: SettingsOpening = SettingsOpener()) {
        self.settingsOpener = settingsOpener
    }

    func openSettings() {
        settingsOpener.open()
    }
}
