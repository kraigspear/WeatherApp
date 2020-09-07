//
//  WeatherDataFetcherTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

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

    func testCurrentConditionsSuccess() throws {
        networkSessionMock.data = load(assetWithName: "CurrentConditions")

        let coordinate = CLLocationCoordinate2D(latitude: 42.96,
                                                longitude: -85.67)

        let expectSuccess = expectation(description: "success")

        var receivedCurrentConditions: CurrentConditions?

        weatherDataFetcher.fetchCurrentConditionsForCoordinate(coordinate) { result in
            switch result {
            case .failure:
                XCTFail("Failure not expected")
            case let .success(conditions):
                receivedCurrentConditions = conditions
                expectSuccess.fulfill()
            }
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

        weatherDataFetcher.fetchCurrentConditionsForCoordinate(coordinate) { result in

            switch result {
            case .failure:
                expectFailed.fulfill()
            case .success:
                XCTFail("Failure not expected")
            }
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectFailed], timeout: 1))
    }

    func testHourlyForecastSuccess() {
        networkSessionMock.data = load(assetWithName: "HourlyForecast")

        let coordinate = CLLocationCoordinate2D(latitude: 42.96,
                                                longitude: -85.67)

        let expectSuccess = expectation(description: "success")

        var receivedForecast: Forecast?

        weatherDataFetcher.fetchForecastForCoordinate(coordinate) { result in

            switch result {
            case .failure:
                XCTFail("Failure not expected")
            case let .success(forecast):
                receivedForecast = forecast
                expectSuccess.fulfill()
            }
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
