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

    private var mainViewModel: MainViewModel!

    private var cancels = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        sinkToMainViewModel()
    }

    private func sinkToMainViewModel() {
        guard !isUnitTest else { return }

        mainViewModel.$temperature.sink { [weak self] temperature in
            self?.temperatureLabel.text = temperature
        }.store(in: &cancels)
    }

    func setup(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
}
