//
//  WeatherDataFetchableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation
@testable import WeatherApp

final class WeatherDataFetchableMock: WeatherDataFetchable {
    private(set) var fetchCalled = 0

    func fetch() {
        fetchCalled += 1
    }
}
