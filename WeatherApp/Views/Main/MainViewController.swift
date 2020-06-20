//
//  MainViewController.swift
//  WeatherApp
//
//  Created by Kraig Spear on 6/20/20.
//  Copyright © 2020 SpearWare. All rights reserved.
//

import Combine
import UIKit

final class MainViewController: UIViewController {
    private let viewModel = MainViewModel()

    /// Embedded view asking for permissions
    @IBOutlet var permissionsView: UIView!

    private var cancels = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        func syncToViewModel() {
            viewModel.$isPermissionViewHidden
                .assign(to: \.isHidden, on: permissionsView).store(in: &cancels)
        }

        syncToViewModel()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }
}
