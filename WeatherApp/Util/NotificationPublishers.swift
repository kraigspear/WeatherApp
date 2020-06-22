//
//  NotificationPublishers.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import UIKit

/// NotificationCenter notifications used in WeatherApp
/// Allows sending notifications in Unit Test
protocol NotificationPublishable {
    /// Called when the App has entered the foreground
    var appWillEnterForeground: AnyPublisher<Void, Never> { get }
}

/// Implementation of `NotificationPublishable`
final class NotificationPublishers: NotificationPublishable {
    /// Wrapper around `UIApplication.willEnterForegroundNotification`
    var appWillEnterForeground: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .flatMap { _ -> AnyPublisher<Void, Never> in
                Just<Void>(()).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
