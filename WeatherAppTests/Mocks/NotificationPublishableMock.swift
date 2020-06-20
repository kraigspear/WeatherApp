//
//  NotificationPublishableMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation
import Combine

@testable import WeatherApp

final class NotificationPublishableMock: NotificationPublishable {
    
    private var appWillEnterForegroundPassThrough = PassthroughSubject<Void, Never>()
    
    var appWillEnterForeground: AnyPublisher<Void, Never> {
        appWillEnterForegroundPassThrough.eraseToAnyPublisher()
    }
    
    func sendAppWillEnterForeground() {
        appWillEnterForegroundPassThrough.send( () )
    }
    
}

