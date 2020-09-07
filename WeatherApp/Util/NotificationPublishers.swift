//
//  NotificationPublishers.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

typealias AppEnteredForegroundClosure = (() -> Void)?

/// NotificationCenter notifications used in WeatherApp
/// Allows sending notifications in Unit Test
protocol NotificationPublishable: AnyObject {
    /// Called when the App has entered the foreground
    var appEnteredForeground: AppEnteredForegroundClosure { get set }
}

/// Implementation of `NotificationPublishable`
final class NotificationPublishers: NSObject, NotificationPublishable {
    var appEnteredForeground: AppEnteredForegroundClosure = nil

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        appEnteredForeground = nil
    }

    @objc func didEnterForeground(_: Notification) {
        appEnteredForeground?()
    }
}
