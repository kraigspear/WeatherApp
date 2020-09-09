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

typealias FetchWeatherForCoordinateResult = Result<CurrentConditions, Error>
typealias FetchHourlyForecastResult = Result<Forecast, Error>

final class WeatherDataFetchableMock: WeatherDataFetchable {
    func fetchCurrentConditionsForCoordinate(_: CLLocationCoordinate2D, completed: @escaping CurrentConditionsCompleted) {
        switch fetchWeatherForCoordinateResult {
        case let .failure(error):
            completed(.failure(error))
        case let .success(currentConditions):
            completed(.success(currentConditions))
        case .none:
            fatalError("not set")
        }
    }

    func fetchForecastForCoordinate(_: CLLocationCoordinate2D, completed: @escaping ForecastCompleted) {
        switch fetchHourlyForecastResult {
        case let .failure(error):
            completed(.failure(error))
        case let .success(forecast):
            completed(.success(forecast))
        case .none:
            fatalError("not set")
        }
    }

    // MARK: - HourlyForecast

    private(set) var fetchHourlyForecastResult: FetchHourlyForecastResult!

    func setupForFetchHourlyForecast(result: FetchHourlyForecastResult) {
        fetchHourlyForecastResult = result
    }

    // MARK: - Current Condtions

    private(set) var fetchWeatherForCoordinateResult: FetchWeatherForCoordinateResult!

    func setupForFetchWeatherForCoordinate(result: FetchWeatherForCoordinateResult) {
        fetchWeatherForCoordinateResult = result
    }
}
