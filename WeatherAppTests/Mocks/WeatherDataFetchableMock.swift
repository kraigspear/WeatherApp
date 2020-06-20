//
//  WeatherDataFetchableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import Foundation

@testable import WeatherApp

final class WeatherDataFetchableMock: WeatherDataFetchable {
    private(set) var fetchCalled = 0
    private(set) var fetchedCoordinate: CLLocationCoordinate2D?
    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D) {
        fetchCalled += 1
        fetchedCoordinate = coordinate
    }
}
