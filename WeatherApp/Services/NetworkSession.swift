//
//  NetworkSession.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation

import Combine
import Foundation
import os.log

typealias NetworkResult = Result<Data, Error>
typealias LoadDataCompletion = (NetworkResult) -> Void

/// Loads data from the network via a Publisher
/// Allows replacing a URLSession with a mock for UnitTest
protocol NetworkSession: AnyObject {
    /// Load data from a URL request, providing a Publisher
    /// - Parameter request: Request to load
    /// - Returns: Publisher with Data or Error
    func loadData(from request: URLRequest) -> AnyPublisher<Data, Error>
}

extension URLSession: NetworkSession {
    /// Load data from a URL request, providing a Publisher
    /// - Parameter from: Request to load
    /// - Returns: Publisher with Data or Error
    func loadData(from request: URLRequest) -> AnyPublisher<Data, Error> {
        Future<Data, Error> { promise in

            self.loadData(from: request) { result in

                switch result {
                case let .failure(error):
                    os_log("LoadData with error: %{public}s",
                           log: LogContext.network,
                           type: .error,
                           error.localizedDescription)
                    promise(.failure(error))
                case let .success(data):
                    os_log("Success loading data",
                           log: LogContext.network,
                           type: .debug)
                    promise(.success(data))
                }
            }

        }.eraseToAnyPublisher()
    }

    /// Load data using a closure
    ///   - Parameter from: Request to load
    ///   - completionHandler: Closure to call with the result of the network operation
    private func loadData(from request: URLRequest,
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
}
