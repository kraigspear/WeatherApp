//
//  ImageCacheMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/22/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit
@testable import WeatherApp

final class ImageCacheMock: ImageCachable {
    private(set) var imageValue: UIImage?

    func setupForImage(_ image: UIImage?) {
        imageValue = image
    }

    private(set) var imageSetCount = 0
    private(set) var keyValue = ""

    subscript(key: String) -> UIImage? {
        get {
            keyValue = key
            return imageValue
        }
        set(newValue) {
            imageSetCount += 1
        }
    }
}
