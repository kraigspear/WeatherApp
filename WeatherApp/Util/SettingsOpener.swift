//
//  SettingsOpener.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

/// Type that can open settings.
protocol SettingsOpenable {
    func open()
}

final class SettingsOpener: SettingsOpenable {
    func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            // If this was to happen we are in invalid state and it doens't make sence to continue.
            // I don't think it would be better to ignore
            preconditionFailure("Not able to convert UIApplication.openSettingsURLString to a URL?")
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
        
    }
}
