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
    private (set) var locationServicesEnabledCalled = 0
    var locationServicesEnabled: Bool {
        locationServicesEnabledCalled += 1
        return locationServicesEnabledValue
    }
    
    
    //MARK: - Setups
    
    func setupForlocationServicesEnabled(_ value: Bool) {
        locationServicesEnabledValue = value
    }
    
}
