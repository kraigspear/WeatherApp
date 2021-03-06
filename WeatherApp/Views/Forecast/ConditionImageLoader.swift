//
//  ConditionImageLoadable.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import os.log
import UIKit

/// Loads condition image from https://openweathermap.org/current
protocol ConditionImageLoadable {
    func loadImageForForecast(at hour: ForecastAtHour) -> AnyPublisher<UIImage, Never>
}

final class ConditionImageLoader {
    private let log = LogContext.conditionImageLoader
    /// Image from SFSymbols to use as the loading image
    private static let defaultSystemImageName = "timelapse"
    /// Default image to use when loading or on error
    private static let defaultImage = UIImage(systemName: defaultSystemImageName)!

    /// Memory cache of condition images
    /// When an image is loaded successfully it is stored in this cache
    /// It this then reused on subsequence request
    private let imageCache: ImageCachable

    /// Session used to access the network
    private let networkSession: NetworkSession

    /// `ConditionImageLoader` Singleton so the same cache is used.
    static let sharedInstance = ConditionImageLoader()

    /// To enforce the Singleton
    init(imageCache: ImageCachable = ImageCache(),
         networkSession: NetworkSession = URLSession.shared) {
        self.imageCache = imageCache
        self.networkSession = networkSession
    }

    /// Loads an image for the ForecastAtHour
    ///
    /// - Parameter at: Hour of the forecast of the condition image
    /// - Returns: Publisher containing the loaded image (or default image on error)
    func loadImageForForecast(at hour: ForecastAtHour) -> AnyPublisher<UIImage, Never> {
        guard let weather = hour.weather.first else {
            return Just<UIImage>(ConditionImageLoader.defaultImage).eraseToAnyPublisher()
        }

        let urlStr = "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"

        if let cachedImage = imageCache[urlStr] {
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

        // Avoid using self in closure
        let cache = imageCache

        let request = URLRequest(url: url)

        return networkSession.loadData(from: request)
            .map { data -> UIImage? in

                if let image = UIImage(data: data) {
                    cache[urlStr] = image
                    return image
                }

                return nil
            }.replaceNil(with: ConditionImageLoader.defaultImage)
            .replaceError(with: ConditionImageLoader.defaultImage).eraseToAnyPublisher()
    }
}
