//
//  NetworkSession.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

import Foundation
import os.log

typealias NetworkResult = Result<Data, Error>
typealias ImageCompletion = (Result<UIImage, Error>) -> Void
typealias LoadDataCompletion = (NetworkResult) -> Void

enum ImageCreateError: Error {
    case failedToCreateImage
}

/// Loads data from the network via a Publisher
/// Allows replacing a URLSession with a mock for UnitTest
protocol NetworkSession: AnyObject {
    /// Load data from a URL request, providing a Publisher
    /// - Parameter request: Request to load
    /// - Parameter completionHandler: Result of loading data
    func loadData(from request: URLRequest,
                  completionHandler: @escaping LoadDataCompletion)

    /*
     Load an image from a URLRequest
     - parameter from: Request to load from
     - parameter completionHandler: Called with the result of loading an image
     */
    func loadImage(from request: URLRequest,
                   completionHandler: @escaping ImageCompletion)
}

extension URLSession: NetworkSession {
    /// Load data using a closure
    ///   - Parameter from: Request to load
    ///   - Parameter completionHandler: Result of loading data
    func loadData(from request: URLRequest,
                  completionHandler: @escaping LoadDataCompletion) {
        let urlString = request.url!.absoluteString

        let logContext = LogContext.network

        os_log("Fetching data for URL: %s",
               log: logContext,
               type: .debug,
               urlString)

        let task = dataTask(with: request) { data, _, error in

            if let error = error {
                os_log("Error calling: %s error: %s",
                       log: logContext,
                       type: .error,
                       urlString,
                       error.localizedDescription)
                completionHandler(NetworkResult.failure(error))
            } else if let data = data {
                os_log("Success calling: %s",
                       log: logContext,
                       type: .debug,
                       urlString)

                completionHandler(NetworkResult.success(data))
            } else {
                fatalError("No error, no data")
            }
        }

        task.resume()
    }

    func loadImage(from request: URLRequest,
                   completionHandler: @escaping ImageCompletion) {
        loadData(from: request) { result in
            switch result {
            case let .failure(error):
                completionHandler(.failure(error))
            case let .success(data):
                if let image = UIImage(data: data) {
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(ImageCreateError.failedToCreateImage))
                }
            }
        }
    }
}
