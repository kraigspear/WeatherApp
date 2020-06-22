//
//  LogContext.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation
import os.log

/// LogContext for OSLog
struct LogContext {
    static let subsystem = "com.spearware.weatherapp"

    static let mainViewModel = OSLog(subsystem: subsystem, category: "🤖MainViewModel")
    static let locationManager = OSLog(subsystem: subsystem, category: "📍LocationManager")
    static let weatherDataFetcher = OSLog(subsystem: subsystem, category: "☔️WeatherDataFetcher")
    static let network = OSLog(subsystem: subsystem, category: "🌎Network")
    static let forecastViewModel = OSLog(subsystem: subsystem, category: "🌤ForecastViewModel")
    static let conditionImageLoader = OSLog(subsystem: subsystem, category: "👩‍🎨conditionImageLoader")
}
