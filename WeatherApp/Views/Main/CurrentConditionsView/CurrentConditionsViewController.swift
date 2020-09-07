//
//  CurrentConditionsViewController.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

/**
  Shows the current conditions.
  ViewModel is shared with the MainViewController (MainViewModel)
 */
final class CurrentConditionsViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var forecastButton: UIButton!

    // MARK: - Overrides

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let identifier = segue.identifier else { return }

        if identifier == "forecast" {
            let forecastViewController = segue.destination as! ForecastViewController

            if let loadedCoordinate = mainViewModel.loadedCoordinate {
                forecastViewController.coordinate = loadedCoordinate
            } else {
                assertionFailure("loadedCoordinate should be been assigned")
            }
        }
    }

    // MARK: - ViewModel

    private var mainViewModel: MainViewModel!

    private var observeViewStateChanged: NSKeyValueObservation?

    /**
     Setup the view from a calling ViewController
     A method is used here to keep the ViewModel private
     - parameter mainViewModel: ViewModel for this ViewController,
     */
    func setup(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel

        let keyPath = \MainViewModel.viewState
        observeViewStateChanged = mainViewModel.observe(keyPath) { [weak self] _, change in

            guard let self = self else { return }
            guard let viewState = change.newValue else { return }

            self.temperatureLabel.text = viewState.temperature
            self.locationLabel.text = viewState.locationName
            self.forecastButton.isEnabled = viewState.isForecastButtonEnabled

            if viewState.isBusy {
                if !self.activityIndicator.isAnimating {
                    self.activityIndicator.startAnimating()
                }
            } else {
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}
