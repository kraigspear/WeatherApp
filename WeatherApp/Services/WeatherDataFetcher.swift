//
//  WeatherDataFetcher.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

protocol WeatherDataFetchable {
    func fetch()
}

final class WeatherDataFetcher: WeatherDataFetchable {
    func fetch() {}
}
