//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Foundation
import Combine
import os.log

final class MainViewModel: ObservableObject {
    
    private let log = LogContext.mainViewModel
    
    private let locationManager: LocationManageable
    
    init(locationManager: LocationManageable = LocationManager()) {
        self.locationManager = locationManager
    }
    
    /**
     Since this App requries knowing the current location
     A embedded view is shown asking for permissions if they
     have not been granted
     */
    @Published var isPermissionViewHidden = false
    
    /// Verify that all ViewModel state is fresh.
    func reload() {
        os_log("reload",
               log: log,
               type: .debug)
        showHideLocationServicesEnabled()
    }
    
    private func showHideLocationServicesEnabled() {
       isPermissionViewHidden = locationManager.locationServicesEnabled
    }
    
}
