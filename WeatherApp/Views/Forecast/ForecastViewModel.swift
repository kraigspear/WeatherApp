//
//  ForecastViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import Foundation
import os.log

final class ForecastViewModel: ObservableObject {
    private let log = LogContext.forecastViewModel

    /// Provides the forecast
    private let weatherDataFetcher: WeatherDataFetchable

    /// Hourly Forecast to show in Forecastt cell
    @Published var hourlyForecast: Forecast?
    @Published var error: Error?

    init(weatherDataFetcher: WeatherDataFetchable = WeatherDataFetcher()) {
        self.weatherDataFetcher = weatherDataFetcher
    }

    func loadForecastFor(coordinate: CLLocationCoordinate2D) {
        os_log("loadForecastFor: lat: %f, lng: %f",
               log: log,
               type: .debug,
               coordinate.latitude,
               coordinate.longitude)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            self.weatherDataFetcher.fetchForecastForCoordinate(coordinate) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .failure(error):
                        os_log("Error loading forecast with error: %{public}s",
                               log: self.log,
                               type: .error,
                               error.localizedDescription)
                        self.error = error
                    case let .success(forecast):
                        os_log("Success loading forecast",
                               log: self.log,
                               type: .debug)
                        self.hourlyForecast = forecast
                    }
                }
            }
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
