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
    private var viewModel: MainViewModel!

    /// We don't want 'real' implementation running as part of a unit test
    private var isUnitTest: Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.isUnitTest
    }

    /// Embedded view asking for permissions
    @IBOutlet var permissionsView: UIView!

    private var cancels = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        func syncToViewModel() {
            viewModel.$isPermissionViewHidden
                .assign(to: \.isHidden, on: permissionsView).store(in: &cancels)

            viewModel.error.sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }.store(in: &cancels)
        }

        if !isUnitTest {
            viewModel = MainViewModel()
            syncToViewModel()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isUnitTest {
            viewModel.reload()
        }
    }

    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}
