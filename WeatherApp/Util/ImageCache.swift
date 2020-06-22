//
//  ImageCache.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/22/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

protocol ImageCachable: AnyObject {
    /// Subscript getting / setting a cached image
    subscript(_: String) -> UIImage? { get set }
}

/// Implementation of `ImageCachable`
final class ImageCache: ImageCachable {
    /// Cache containing, cached images
    private let cache = NSCache<NSString, UIImage>()

    /// Get an image from the cache
    /// - parameter forKey: Key of the image to retrive
    /// - returns: Image from the cache, or nil if the image doens't exist
    private func image(forKey key: String) -> UIImage? {
        if let cachedImage = cache.object(forKey: NSString(string: key)) {
            return cachedImage
        }

        return nil
    }

    /// Put an image in the cache
    /// - parameter image: Image to put in the cache
    /// - parameter forKey: Key to associate with this image
    private func setImage(_ image: UIImage, forKey: String) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }

    subscript(key: String) -> UIImage? {
        get { image(forKey: key) }
        set {
            if let image = newValue {
                setImage(image, forKey: key)
            } else {
                cache.removeObject(forKey: NSString(string: key))
            }
        }
    }
}
