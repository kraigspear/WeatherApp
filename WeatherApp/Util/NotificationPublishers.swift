//
//  NotificationPublishers.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import UIKit

protocol NotificationPublishable {
    var appWillEnterForeground: AnyPublisher<Void, Never> { get }
}

final class NotificationPublishers: NotificationPublishable {
    var appWillEnterForeground: AnyPublisher<Void, Never> {
        return NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .flatMap { _ -> AnyPublisher<Void, Never> in
                Just<Void>(()).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
