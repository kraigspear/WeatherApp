//
//  NotificationPublishers.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit
import Combine

protocol NotificationPublishable {
    var appWillEnterForeground: AnyPublisher<Void, Never> { get }
}

final class NotificationPublishers: NotificationPublishable {
    
    var appWillEnterForeground: AnyPublisher<Void, Never> {
        return NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .flatMap { notification -> AnyPublisher<Void, Never> in
                return Just<Void>(()).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
}
