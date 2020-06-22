//
//  NetworkSessionMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import Foundation
@testable import WeatherApp

/// Mock for `NetworkSession` to allow testing

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var error: Error?

    private(set) var loadDataCount = 0

    func loadData(from _: URLRequest) -> AnyPublisher<Data, Error> {
        if let data = data {
            loadDataCount += 1
            return Just<Data>(data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        if let error = error {
            return Fail<Data, Error>(error: error).eraseToAnyPublisher()
        }

        fatalError("Missing data or error")
    }
}
