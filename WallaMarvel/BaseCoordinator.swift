//
//  BaseCoordinator.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 27/05/2025.
//


import UIKit

enum ToasterType {
    case informative
    case error

    var defaultTitle: String {
        switch self {
        case .informative: return NSLocalizedString("Info", comment: "")
        case .error: return NSLocalizedString("Error", comment: "")
        }
    }
    
    var defaultMessage: String {
        switch self {
        case .informative: return NSLocalizedString("Operation completed successfully.", comment: "")
        case .error: return NSLocalizedString("some_error", comment: "" )
        }
    }
}

class BaseCoordinator: Coordinator {
    func start() {}
    
    var navigationController: UINavigationController
    private var loadingOverlay: UIView?
    
    func showToaster(_ message: String? = nil, toasterType: ToasterType = .error) {
        let message = message ?? toasterType.defaultMessage
        let alertController = UIAlertController(title: toasterType.defaultTitle, message: message, preferredStyle: .alert)
        navigationController.present(alertController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    func showLoading() {
        guard loadingOverlay == nil else { return }
        
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        overlay.addSubview(spinner)
        navigationController.view.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: navigationController.view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
        loadingOverlay = overlay
    }
    
    func hideLoading() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
