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

typealias CurrentConditionsCompleted = (Result<CurrentConditions, Error>) -> Void
typealias ForecastCompleted = (Result<Forecast, Error>) -> Void

/// Fetches weather data from the Weather Service
protocol WeatherDataFetchable {
    /**
     Fetch the current conditions at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the current conditions
     - parameter result: Result of getting the current conditions
     **/
    func fetchCurrentConditionsForCoordinate(_ coordinate: CLLocationCoordinate2D,
                                             completed: @escaping CurrentConditionsCompleted)
    /**
     Fetch the forecast at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the forecast
     - parameter result: Result of getting the forecast
     */
    func fetchForecastForCoordinate(_ coordinate: CLLocationCoordinate2D,
                                    completed: @escaping ForecastCompleted)
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
    func fetchCurrentConditionsForCoordinate(_ coordinate: CLLocationCoordinate2D,
                                             completed: @escaping CurrentConditionsCompleted) {
        os_log("fetchWeatherForCoordinate: %f,%f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)

        func urlRequest(from coordinate: CLLocationCoordinate2D) -> URLRequest {
            let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(appId)&units=imperial"

            os_log("URL: %s",
                   log: log,
                   type: .debug,
                   urlStr)

            return URLRequest(url: URL(string: urlStr)!)
        }

        networkSession.loadData(from: urlRequest(from: coordinate)) { result in

            switch result {
            case let .failure(error):
                completed(.failure(error))
            case let .success(data):
                do {
                    let currentConditions = try JSONDecoder().decode(CurrentConditions.self, from: data)
                    completed(.success(currentConditions))
                } catch {
                    completed(.failure(error))
                }
            }
        }
    }

    /**
     Fetch the forecast at a given coordinate
     - parameter coordinate: Coordinate of the location to retrieve the forecast
     - returns: Publisher with the Forecast or Error
     */
    func fetchForecastForCoordinate(_ coordinate: CLLocationCoordinate2D,
                                    completed: @escaping ForecastCompleted) {
        os_log("fetchForecastForCoordinate: %f,%f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)

        func urlRequest(from coordinate: CLLocationCoordinate2D) -> URLRequest {
            let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(appId)&units=imperial"

            os_log("URL: %s",
                   log: log,
                   type: .debug,
                   urlStr)

            return URLRequest(url: URL(string: urlStr)!)
        }

        networkSession.loadData(from: urlRequest(from: coordinate)) { result in

            switch result {
            case let .failure(error):
                completed(.failure(error))
            case let .success(data):
                DispatchQueue.global().async {
                    do {
                        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
                        DispatchQueue.main.async {
                            completed(.success(forecast))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completed(.failure(error))
                        }
                    }
                }
            }
        }
    }
}
