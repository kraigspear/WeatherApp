//
//  CurrentConditionsViewController.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
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

    override func viewDidLoad() {
        super.viewDidLoad()
        sinkToMainViewModel()
    }

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
    /// Any publishers that should live as long as this ViewController
    private var cancels = Set<AnyCancellable>()

    /**
     Setup the view from a calling ViewController
     A method is used here to keep the ViewModel private
     - parameter mainViewModel: ViewModel for this ViewController,
     */
    func setup(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }

    /// Wireup ViewModel properties for what is shown in this View
    private func sinkToMainViewModel() {
        guard !isUnitTest else { return }

        mainViewModel.$temperature.sink { [weak self] temperature in
            self?.temperatureLabel.text = temperature
        }.store(in: &cancels)

        mainViewModel.$locationName.sink { [weak self] locationName in
            self?.locationLabel.text = locationName
        }.store(in: &cancels)

        mainViewModel.$isForecastButtonEnabled.sink { [weak self] isForecastButtonEnabled in
            self?.forecastButton.isEnabled = isForecastButtonEnabled
        }.store(in: &cancels)

        mainViewModel.$isBusy.sink { [weak self] isBusy in
            guard let self = self else { return }

            if isBusy {
                if !self.activityIndicator.isAnimating {
                    self.activityIndicator.startAnimating()
                }
            } else {
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
            }

        }.store(in: &cancels)
    }
}
