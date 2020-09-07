//
//  NotificationPublishableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

@testable import WeatherApp

final class NotificationPublishableMock: NotificationPublishable {
    var appEnteredForeground: AppEnteredForegroundClosure = nil

    func sendAppWillEnterForeground() {
        appEnteredForeground?()
    }
}
