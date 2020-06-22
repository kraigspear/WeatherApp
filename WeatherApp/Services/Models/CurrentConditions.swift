//
//  CurrentConditions.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

/// Current Conditions
/// Model object for https://openweathermap.org/current
struct CurrentConditions: Decodable {
    enum CodingKeys: String, CodingKey {
        case locationName = "name"
        case main
    }

    /// The name of the location for this `CurrentConditions`
    let locationName: String
    /// The main part of the current conditions
    let main: CurrentConditionsMain
}

struct CurrentConditionsMain: Decodable {
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }

    /// The temperature in Fahrenheit for the current conditions
    let temperature: Double
}
