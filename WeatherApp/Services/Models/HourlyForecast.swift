//
//  Forecast.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

struct HourlyForecast: Decodable {
    let list: [Hour]
}

struct Hour: Decodable {
    enum CodingKeys: String, CodingKey {
        case dateTimeEpoch = "dt"
        case main
        case weather
    }

    let dateTimeEpoch: Int
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let icon: String
}
