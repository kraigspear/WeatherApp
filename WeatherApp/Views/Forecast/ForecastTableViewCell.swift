//
//  ForecastTableViewCell.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import UIKit

struct ForecastDisplay {
    let date: String
    let temperature: String
    let hour: ForecastAtHour
}

final class ForecastTableViewCell: UITableViewCell {
    static let cellId = "forecastTableViewCell"

    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var conditionImageView: UIImageView!

    func configure(_ forecast: ForecastDisplay) {
        dateTimeLabel.text = forecast.date
        temperatureLabel.text = forecast.temperature
        conditionImageView.image = UIImage(systemName: "timelapse")!

        ConditionImageLoader.sharedInstance.loadImageForForecast(at: forecast.hour) { [weak self] image in
            assert(Thread.isMainThread, "Main Thread")
            self?.conditionImageView.image = image
        }
    }
}
