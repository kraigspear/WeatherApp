//
//  ForecastViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import os.log

final class ForecastViewModel: ObservableObject {
    private let log = LogContext.forecastViewModel

    private let weatherDataFetcher: WeatherDataFetchable

    init(weatherDataFetcher: WeatherDataFetchable = WeatherDataFetcher()) {
        self.weatherDataFetcher = weatherDataFetcher
    }

    func loadForecastFor(coordinate: CLLocationCoordinate2D) {
        os_log("loadForecastFor: lat: %f, lng: %f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)
    }
}
