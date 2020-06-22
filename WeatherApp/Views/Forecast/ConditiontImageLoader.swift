//
//  ConditiontImageLoader.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import os.log
import UIKit

protocol ConditiontImageLoadable {
    func loadImage(hour: Hour) -> AnyPublisher<UIImage, Never>
}

final class ConditionImageLoader {
    private let defaultImage = UIImage(systemName: "timelapse")!

    private let log = LogContext.conditionImageLoader

    /// Memory cache of condition images
    private let cache = NSCache<NSString, UIImage>()

    static let sharedInstance = ConditionImageLoader()

    func loadImage(hour: Hour) -> AnyPublisher<UIImage, Never> {
        guard let weather = hour.weather.first else {
            return Just<UIImage>(defaultImage).eraseToAnyPublisher()
        }

        let urlStr = "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"
        let nsUrlStr = NSString(string: urlStr)

        if let cachedImage = cache.object(forKey: nsUrlStr) {
            os_log("Loading from cache: %s",
                   log: log,
                   type: .debug,
                   urlStr)

            return Just<UIImage>(cachedImage).eraseToAnyPublisher()
        }

        let url = URL(string: urlStr)!

        os_log("Downloading image: %s",
               log: log,
               type: .debug,
               urlStr)

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .map { data -> UIImage? in

                if let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: nsUrlStr)
                    return image
                }

                return nil
            }.replaceNil(with: defaultImage)
            .replaceError(with: defaultImage).eraseToAnyPublisher()
    }
}
