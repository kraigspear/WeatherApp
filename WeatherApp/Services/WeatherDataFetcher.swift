//
//  WeatherDataFetcher.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import Foundation
import os.log

protocol WeatherDataFetchable {
    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D)
}

final class WeatherDataFetcher: WeatherDataFetchable {
    private let log = LogContext.weatherDataFetcher

    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D) {
        os_log("fetchWeatherForCoordinate: %f,%f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)
    }
}
