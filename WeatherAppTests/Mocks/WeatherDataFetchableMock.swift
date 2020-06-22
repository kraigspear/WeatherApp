//
//  WeatherDataFetchableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

@testable import WeatherApp

typealias FetchWeatherForCoordinateResult = Result<CurrentConditions, Error>
typealias FetchHourlyForecastResult = Result<HourlyForecast, Error>

final class WeatherDataFetchableMock: WeatherDataFetchable {
    // MARK: - HourlyForecast

    private(set) var fetchHourlyForecastResult: FetchHourlyForecastResult!

    func setupForFetchHourlyForecast(result: FetchHourlyForecastResult) {
        fetchHourlyForecastResult = result
    }

    func fetchHourlyForecast(_: CLLocationCoordinate2D) -> AnyPublisher<HourlyForecast, Error> {
        switch fetchHourlyForecastResult {
        case let .success(hourlyForecast):
            return Just<HourlyForecast>(hourlyForecast)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case let .failure(error):
            return Fail<HourlyForecast, Error>(error: error).eraseToAnyPublisher()
        case .none:
            fatalError("not set")
        }
    }

    // MARK: - Current Condtions

    private(set) var fetchWeatherForCoordinateResult: FetchWeatherForCoordinateResult!

    func setupForFetchWeatherForCoordinate(result: FetchWeatherForCoordinateResult) {
        fetchWeatherForCoordinateResult = result
    }

    func fetchWeatherForCoordinate(_: CLLocationCoordinate2D) -> AnyPublisher<CurrentConditions, Error> {
        switch fetchWeatherForCoordinateResult {
        case let .failure(error):
            return Fail<CurrentConditions, Error>(error: error).eraseToAnyPublisher()
        case let .success(currentConditions):
            return Just<CurrentConditions>(currentConditions)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .none:
            fatalError("not set")
        }
    }
}
