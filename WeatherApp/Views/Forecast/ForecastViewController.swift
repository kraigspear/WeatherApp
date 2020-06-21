//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import CoreLocation
import UIKit

final class ForecastViewController: UITableViewController {
    private var viewModel = ForecastViewModel()

    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("5 Day Forecast", comment: "")

        precondition(coordinate != nil, "coordinate should be set prior to ForecastViewController loading")

        viewModel.loadForecastFor(coordinate: coordinate!)
    }
}
