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

enum FetchWeatherForCoordinateResult {
    case success(CurrentConditions)
    case failure(Error)
}

final class WeatherDataFetchableMock: WeatherDataFetchable {
    private(set) var fetchWeatherForCoordinateResult: FetchWeatherForCoordinateResult!

    func setupForfetchWeatherForCoordinate(result: FetchWeatherForCoordinateResult) {
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
