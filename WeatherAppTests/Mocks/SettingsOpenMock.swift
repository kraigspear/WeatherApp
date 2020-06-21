//
//  SettingsOpenMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation
@testable import WeatherApp

final class SettingsOpenMock: SettingsOpenable {
    private(set) var openCalled = 0

    func open() {
        openCalled += 1
    }
}
