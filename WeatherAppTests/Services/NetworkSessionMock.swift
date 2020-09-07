//
//  NetworkSessionMock.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import UIKit
@testable import WeatherApp

/// Mock for `NetworkSession` to allow testing

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var error: Error?

    private(set) var loadDataCount = 0

    func loadData(from _: URLRequest, completionHandler: @escaping LoadDataCompletion) {
        if let data = data {
            loadDataCount += 1
            completionHandler(.success(data))
            return
        }

        if let error = error {
            completionHandler(.failure(error))
            return
        }

        fatalError("Missing data or error")
    }

    var loadDataModel: Decodable?

    func loadImage(from _: URLRequest,
                   completionHandler: @escaping ImageCompletion) {
        let image = UIImage(data: data!)!
        completionHandler(.success(image))
    }
}
