//
//  ForecastViewModelTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/22/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
@testable import WeatherApp
import XCTest

private enum SomeError: Error {
    case whoops
}

final class ForecastViewModelTest: XCTestCase {
    private var weatherDataFetchableMock: WeatherDataFetchableMock!

    private var forecastViewModel: ForecastViewModel!
    private var loadCancel: AnyCancellable?

    override func setUpWithError() throws {
        weatherDataFetchableMock = WeatherDataFetchableMock()
        forecastViewModel = ForecastViewModel(weatherDataFetcher: weatherDataFetchableMock)
    }

    override func tearDownWithError() throws {
        loadCancel = nil
    }

    func testForecastDisplay() throws {
        let forecast: Forecast = loadModel(from: "HourlyForecast")

        let forecastAtHour = forecast.forecastHours.first!
        let forecastDisplay = forecastViewModel.forecastDisplay(from: forecastAtHour)

        XCTAssertEqual("06/21/20 2:00 PM", forecastDisplay.date)
        XCTAssertEqual(78.21, forecastDisplay.hour.main.temperature)
        XCTAssertEqual("10d", forecastDisplay.hour.weather.first!.icon)
    }

    func testViewModelPopulatedWhenForecastWasLoaded() {
        let forecast: Forecast = loadModel(from: "HourlyForecast")

        let result = FetchHourlyForecastResult.success(forecast)

        weatherDataFetchableMock.setupForFetchHourlyForecast(result: result)

        let coordinate = CLLocationCoordinate2D(latitude: 42.9634,
                                                longitude: -85.6681)

        let expect = expectation(description: "forecastLoaded")

        var loadedForecast: Forecast?

        loadCancel = forecastViewModel.$hourlyForecast.sink { forecast in
            if let forecast = forecast {
                loadedForecast = forecast
                expect.fulfill()
            }
        }

        forecastViewModel.loadForecastFor(coordinate: coordinate)

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 1))
        XCTAssertNotNil(loadedForecast)
    }

    func testViewModelErrorWhenErrorLoadingForecast() {
        let result = FetchHourlyForecastResult.failure(SomeError.whoops)

        weatherDataFetchableMock.setupForFetchHourlyForecast(result: result)

        let coordinate = CLLocationCoordinate2D(latitude: 42.9634,
                                                longitude: -85.6681)

        let expect = expectation(description: "error")

        var receivedError: Error?

        loadCancel = forecastViewModel.$error.sink { error in

            if let error = error {
                receivedError = error
                expect.fulfill()
            }
        }

        forecastViewModel.loadForecastFor(coordinate: coordinate)

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 1))
        XCTAssertNotNil(receivedError)
    }
}
