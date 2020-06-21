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

protocol WeatherDataFetchable {
    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentConditions, Error>
}

final class WeatherDataFetcher: WeatherDataFetchable {
    private let log = LogContext.weatherDataFetcher

    private let urlSession: NetworkSession

    // NOTE: It's ill advised to store keys in source code, but it's beyond the scope of this example
    // to handle properly
    private let appId = "130ed6948ed553932c067948646fc6e6"

    init(urlSession: NetworkSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchWeatherForCoordinate(_ coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentConditions, Error> {
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

        return urlSession.loadData(from: urlRequest(coordinate))
            .decode(type: CurrentConditions.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
