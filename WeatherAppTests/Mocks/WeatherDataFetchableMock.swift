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
    var fetchWeatherForCoordinateCalled: ((CLLocationCoordinate2D) -> Void)?
    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D) {
        fetchWeatherForCoordinateCalled?(coordinate)
    }
}
