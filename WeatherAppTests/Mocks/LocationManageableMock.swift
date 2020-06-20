//
//  LocationManageableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation
@testable import WeatherApp

final class LocationManageableMock: LocationManageable {
    
    private var locationServicesEnabledValue = false
    
    var locationServicesEnabled: Bool {
        locationServicesEnabledValue
    }
    
    
    //MARK: - Setups
    
    func setupForlocationServicesEnabled(_ value: Bool) {
        locationServicesEnabledValue = value
    }
    
}
