//
//  SettingsOpener.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import os.log
import UIKit

/// Open iOS Settings
protocol SettingsOpening {
    /// Open iOS Settings
    func open()
}

/// Implementation of `SettingsOpening` allows opening settings
final class SettingsOpener: SettingsOpening {
    private let log = LogContext.general

    /// Open iOS Settings
    func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            // If this was to happen we are in invalid state and it doesn't make sense to continue.
            // The URL comes from the framework
            preconditionFailure("Not able to convert UIApplication.openSettingsURLString to a URL?")
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            os_log("Can't open settings URL",
                   log: log,
                   type: .error)
            assertionFailure("Can't open settings URL")
        }
    }
}
