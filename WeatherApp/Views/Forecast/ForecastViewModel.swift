//
//  ForecastViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import os.log

final class ForecastViewModel: ObservableObject {
    private let log = LogContext.forecastViewModel

    private let weatherDataFetcher: WeatherDataFetchable

    @Published var hourlyForecast: Forecast?
    @Published var error: Error?

    init(weatherDataFetcher: WeatherDataFetchable = WeatherDataFetcher()) {
        self.weatherDataFetcher = weatherDataFetcher
    }

    private var fetchHourlyCancel: AnyCancellable?
    func loadForecastFor(coordinate: CLLocationCoordinate2D) {
        os_log("loadForecastFor: lat: %f, lng: %f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)

        fetchHourlyCancel = weatherDataFetcher.fetchForecastForCoordinate(coordinate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in

                guard let self = self else { return }

                defer { self.fetchHourlyCancel = nil }

                switch completed {
                case let .failure(error):
                    self.error = error
                case .finished:
                    break
                }

        }) { hourlyForecast in
                self.hourlyForecast = hourlyForecast
            }
    }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy h:mm a"
        return dateFormatter
    }()

    func forecastDisplay(from hour: ForecastAtHour) -> ForecastDisplay {
        let date = Date(timeIntervalSince1970: Double(hour.dateTimeEpoch))
        let temperature = "\(Int(hour.main.temperature))℉"
        return ForecastDisplay(date: dateFormatter.string(from: date),
                               temperature: temperature,
                               hour: hour)
    }
}
