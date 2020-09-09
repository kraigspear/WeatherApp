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

    private var hourlyForecast: Forecast? {
        didSet {
            tableView.reloadData()
        }
    }

    private var observeViewStateChanged: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("5 Day Forecast", comment: "")

        precondition(coordinate != nil, "coordinate should be set prior to ForecastViewController loading")

        let keyPath = \ForecastViewModel.viewState
        observeViewStateChanged = viewModel.observe(keyPath) { [weak self] viewModel, change in
            guard let self = self else { return }
            self.hourlyForecast = viewModel.viewState.hourlyForecast
        }

        viewModel.loadForecastFor(coordinate: coordinate!)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        hourlyForecast?.forecastHours.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCell.cellId, for: indexPath) as! ForecastTableViewCell
        let forecast = hourlyForecast!.forecastHours[indexPath.row]

        let forecastDisplay = viewModel.forecastDisplay(from: forecast)

        cell.configure(forecastDisplay)

        return cell
    }
}
