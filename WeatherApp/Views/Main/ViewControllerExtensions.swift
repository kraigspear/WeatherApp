//
//  ViewControllerExtensions.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/21/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import UIKit

extension UIViewController {
    /// We don't want 'real' implementation running as part of a unit test
    var isUnitTest: Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.isUnitTest
    }
}
