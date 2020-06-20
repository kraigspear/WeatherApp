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
    
    static let mainViewModel = OSLog(subsystem: subsystem, category: "MainViewModel")
    
}
