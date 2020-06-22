//
//  Forecast.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

/// Weather Forecast
/// Model object for https://openweathermap.org/forecast5
struct Forecast: Decodable {
    enum CodingKeys: String, CodingKey {
        case forecastHours = "list"
    }

    /// A collection forecast by a given hour
    let forecastHours: [ForecastAtHour]
}

/// A weather forecast at a given hour
struct ForecastAtHour: Decodable {
    enum CodingKeys: String, CodingKey {
        case dateTimeEpoch = "dt"
        case main
        case weather
    }

    /// The date time given as the number of seconds since 1/1/1970
    let dateTimeEpoch: Int
    /// The main part of the forecast
    let main: Main
    /// Contains the condition icon
    let weather: [Weather]
}

/// Main part of the forecast containing the temperature
struct Main: Decodable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }

    /// The temperature in Fahrenheit for a forecast
    let temperature: Double
}

/// Weather section
struct Weather: Decodable {
    /// icon image for a given weather condition
    let icon: String
}
