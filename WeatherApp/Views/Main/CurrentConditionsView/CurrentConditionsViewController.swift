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

 */
final class CurrentConditionsViewController: UIViewController {
    @IBOutlet var temperatureLabel: UILabel!

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var mainViewModel: MainViewModel!

    private var cancels = Set<AnyCancellable>()

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

    private func sinkToMainViewModel() {
        guard !isUnitTest else { return }

        mainViewModel.$temperature.sink { [weak self] temperature in
            self?.temperatureLabel.text = temperature
        }.store(in: &cancels)

        mainViewModel.$locationName.sink { [weak self] locationName in
            self?.locationLabel.text = locationName
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

    func setup(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
}
