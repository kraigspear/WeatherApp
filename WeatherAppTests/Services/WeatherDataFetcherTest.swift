//
//  WeatherDataFetcherTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import XCTest

@testable import WeatherApp

private enum SomeError: Error {
    case error
}

final class WeatherDataFetcherTest: XCTestCase {
    private var networkSessionMock: NetworkSessionMock!
    private var weatherDataFetcher: WeatherDataFetcher!

    override func setUpWithError() throws {
        networkSessionMock = NetworkSessionMock()
        weatherDataFetcher = WeatherDataFetcher(networkSession: networkSessionMock)
    }

    override func tearDownWithError() throws {
        fetchWeatherCancel = nil
    }

    private var fetchWeatherCancel: AnyCancellable?

    func testCurrentConditionsSuccess() throws {
        networkSessionMock.data = load(assetWithName: "CurrentConditions")

        let coordinate = CLLocationCoordinate2D(latitude: 42.96,
                                                longitude: -85.67)

        let expectSuccess = expectation(description: "success")

        var receivedCurrentConditions: CurrentConditions?

        fetchWeatherCancel = weatherDataFetcher.fetchCurrentConditionsForCoordinate(coordinate)
            .sink(receiveCompletion: { completed in

                switch completed {
                case .failure:
                    XCTFail("Failure not expected")
                case .finished:
                    expectSuccess.fulfill()
                }

            }) { currentConditions in
                receivedCurrentConditions = currentConditions
            }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectSuccess], timeout: 1))
        XCTAssertNotNil(receivedCurrentConditions)
        XCTAssertEqual(70.36, receivedCurrentConditions!.main.temperature)
    }

    func testCurrentConditionsError() {
        networkSessionMock.error = SomeError.error
        let expectFailed = expectation(description: "failed")

        let coordinate = CLLocationCoordinate2D(latitude: 42.96,
                                                longitude: -85.67)

        fetchWeatherCancel = weatherDataFetcher.fetchCurrentConditionsForCoordinate(coordinate)
            .sink(receiveCompletion: { completed in

                switch completed {
                case .failure:
                    expectFailed.fulfill()
                case .finished:
                    XCTFail("Failure not expected")
                }

                   }) { _ in
                XCTFail("Shouldn't have received value")
            }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectFailed], timeout: 1))
    }

    func testHourlyForecastSuccess() {
        networkSessionMock.data = load(assetWithName: "HourlyForecast")

        let coordinate = CLLocationCoordinate2D(latitude: 42.96,
                                                longitude: -85.67)

        let expectSuccess = expectation(description: "success")

        var receivedForecast: Forecast?

        fetchWeatherCancel = weatherDataFetcher.fetchForecastForCoordinate(coordinate)
            .sink(receiveCompletion: { completed in

                switch completed {
                case .failure:
                    XCTFail("Failure not expected")
                case .finished:
                    expectSuccess.fulfill()
                }

            }) { hourlyForecast in
                receivedForecast = hourlyForecast
            }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectSuccess], timeout: 1))

        XCTAssertNotNil(receivedForecast)
        XCTAssertEqual(40, receivedForecast!.forecastHours.count)
        let firstHour = receivedForecast!.forecastHours.first!

        XCTAssertEqual(1_592_762_400, firstHour.dateTimeEpoch)
        XCTAssertEqual(78.21, firstHour.main.temperature)
        XCTAssertEqual("10d", firstHour.weather.first!.icon)
    }
}
