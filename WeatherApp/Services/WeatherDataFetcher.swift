//
//  WeatherDataFetcher.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import Foundation

protocol WeatherDataFetchable {
    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D)
}

final class WeatherDataFetcher: WeatherDataFetchable {
    func fetchWeatherForCoordinate(_: CLLocationCoordinate2D) {}
}
