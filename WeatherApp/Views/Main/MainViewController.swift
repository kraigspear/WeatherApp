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
    /// Embedded view asking for permissions
    @IBOutlet var permissionsView: UIView!

    private var cancels = Set<AnyCancellable>()

    // MARK: - Overrides

    lazy var viewModel: MainViewModel = {
        let viewModel = MainViewModel()

        func syncToViewModel() {
            viewModel.$isPermissionViewHidden
                .assign(to: \.isHidden, on: permissionsView).store(in: &cancels)

            viewModel.error.sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }.store(in: &cancels)
        }

        syncToViewModel()

        return viewModel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Current Temperature", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isUnitTest {
            viewModel.reload()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard !isUnitTest else { return }

        if segue.identifier == "currentConditions" {
            let currentConditionsViewController = segue.destination as! CurrentConditionsViewController
            currentConditionsViewController.setup(mainViewModel: viewModel)
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
