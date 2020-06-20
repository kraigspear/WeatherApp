//
//  LocationPermissionViewController.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

final class LocationPermissionViewController: UIViewController {
    
    private let viewModel = LocationPermissionViewModel()
    
    @IBAction func openInSettingsAction(_ sender: Any) {
        viewModel.openSettings()
    }
    
}
