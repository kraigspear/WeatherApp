//
//  WeatherDataFetcher.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import os.log

/// Fetches weather data from the Weather Service
protocol WeatherDataFetchable {
    /**
     Fetch the current conditions at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the current conditions
     - returns: Publisher with CurrentConditions or an Error
     **/
    func fetchCurrentConditionsForCoordinate(_ coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentConditions, Error>
    /**
     Fetch the forecast at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the forecast
     - returns: Publisher with the Forecast or Error
     */
    func fetchForecastForCoordinate(_ coordinate: CLLocationCoordinate2D) -> AnyPublisher<Forecast, Error>
}

/// Fetches weather data from the Weather Service
/// Implementation of `WeatherDataFetchable`
final class WeatherDataFetcher: WeatherDataFetchable {
    private let log = LogContext.weatherDataFetcher

    /// Loads data from the Network
    private let networkSession: NetworkSession

    // NOTE: It's ill advised to store keys in source code, but it's beyond the scope of this example
    // to handle properly
    private let appId = "130ed6948ed553932c067948646fc6e6"

    /**
     Initialize with a `NetworkSession`
     - parameter networkSession: Loads data from the network
     */
    init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
    }

    // MARK: - Fetch

    /**
     Fetch the current conditions at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the current conditions
     - returns: Publisher with CurrentConditions or an Error
     **/
    func fetchCurrentConditionsForCoordinate(_ coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentConditions, Error> {
        os_log("fetchWeatherForCoordinate: %f,%f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)

        func urlRequest(_ coordinate: CLLocationCoordinate2D) -> URLRequest {
            let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(appId)&units=imperial"

            os_log("URL: %s",
                   log: log,
                   type: .debug,
                   urlStr)

            return URLRequest(url: URL(string: urlStr)!)
        }

        return networkSession.loadData(from: urlRequest(coordinate))
            .decode(type: CurrentConditions.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /**
     Fetch the forecast at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the forecast
     - returns: Publisher with the Forecast or Error
     */
    func fetchForecastForCoordinate(_ coordinate: CLLocationCoordinate2D) -> AnyPublisher<Forecast, Error> {
        os_log("fetchForecastForCoordinate: %f,%f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)

        func urlRequest(_ coordinate: CLLocationCoordinate2D) -> URLRequest {
            let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(appId)&units=imperial"

            os_log("URL: %s",
                   log: log,
                   type: .debug,
                   urlStr)

            return URLRequest(url: URL(string: urlStr)!)
        }

        return networkSession.loadData(from: urlRequest(coordinate))
            .decode(type: Forecast.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
