//
//  ConditionImageLoaderTest.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/22/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
@testable import WeatherApp
import XCTest

final class ConditionImageLoaderTest: XCTestCase {
    private var imageCacheMock: ImageCacheMock!
    private var networkSessionMock: NetworkSessionMock!

    private var conditionImageLoader: ConditionImageLoader!

    override func setUpWithError() throws {
        imageCacheMock = ImageCacheMock()
        networkSessionMock = NetworkSessionMock()

        conditionImageLoader = ConditionImageLoader(imageCache: imageCacheMock,
                                                    networkSession: networkSessionMock)
    }

    func testImageRetrivedFromCacheWhenImageIsInCache() throws {
        let image = UIImage(systemName: "paperplane")!
        imageCacheMock.setupForImage(image)

        let forecast: Forecast = loadModel(from: "HourlyForecast")

        let expectLoaded = expectation(description: "loaded")

        var loadedImage: UIImage?

        conditionImageLoader.loadImageForForecast(at: forecast.forecastHours.first!) { image in

            loadedImage = image
            expectLoaded.fulfill()
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectLoaded], timeout: 1))

        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(image, loadedImage!)
    }

    func testImageDownloadedFromNetworkWhenImageNotInCache() {
        let forecast: Forecast = loadModel(from: "HourlyForecast")

        let downloadedImage = UIImage(systemName: "timelapse")!
        networkSessionMock.data = downloadedImage.pngData()!

        var loadedImage: UIImage?
        let expectLoaded = expectation(description: "loaded")

        conditionImageLoader.loadImageForForecast(at: forecast.forecastHours.first!) { image in
            loadedImage = image
            expectLoaded.fulfill()
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectLoaded], timeout: 1))
        XCTAssertNotNil(loadedImage)
    }

    func testImageAddedToCacheWhenImageWasDownloaded() {
        let forecast: Forecast = loadModel(from: "HourlyForecast")

        let downloadedImage = UIImage(systemName: "timelapse")!
        networkSessionMock.data = downloadedImage.pngData()!

        var loadedImage: UIImage?
        let expectLoaded = expectation(description: "loaded")

        conditionImageLoader.loadImageForForecast(at: forecast.forecastHours.first!) { image in
            loadedImage = image
            expectLoaded.fulfill()
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectLoaded], timeout: 1))
        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(1, imageCacheMock.imageSetCount)
    }
}
