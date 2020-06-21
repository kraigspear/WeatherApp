//
//  TestDataLoader.swift
//  WeatherAppTests
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

protocol TestDataLoadable: AnyObject {}

extension TestDataLoadable {
    /// Load data from the bundle from a file
    /// - Parameter fileWithName: Name of (JSON) file to load
    /// - Returns: Data loaded from a file
    func loadJSONData(fileWithName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: fileWithName, ofType: "json")!
        let url = URL(fileURLWithPath: path)
        return try! Data(contentsOf: url)
    }

    /// Load data from an Asset
    /// If the data doesn't exist CRASH
    /// - Parameter assetWithName: Name of asset to load data from
    /// - Returns: Data loaded from a file
    func load(assetWithName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        return NSDataAsset(name: assetWithName, bundle: bundle)!.data
    }

    /// Load a model object from an asset
    /// Asset must exist, or there will be a crash
    /// - Parameter assetWithName: Name of asset to load a model from
    /// - Returns: Model object from asset
    func loadModel<Model>(from assetWithName: String) -> Model
        where Model: Decodable {
        let data = load(assetWithName: assetWithName)
        return try! JSONDecoder().decode(Model.self, from: data)
    }
}
