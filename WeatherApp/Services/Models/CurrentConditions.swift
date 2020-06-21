//
//  CurrentConditions.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

struct CurrentConditions: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case main
    }

    let name: String
    let main: CurrentConditionsMain
}

struct CurrentConditionsMain: Decodable {
    let temp: Double
}
