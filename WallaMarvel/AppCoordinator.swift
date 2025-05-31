//
//  AppCoordinator.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 26/05/2025.
//
import UIKit

protocol Coordinator {
    func showLoading()
    func hideLoading()
    func showToaster(_ message: String?, toasterType: ToasterType)
    func start()
}

class AppCoordinator: Coordinator {
    private var loadingOverlay: UIView?
    private var tabBarController: UITabBarController
    private var listHeroesCoordinator: ListHeroesCoordinator?
    private var favoritesCoordinator: FavoriteHeroesCoordinator?

    init() {
        self.tabBarController = UITabBarController()
    }

    func start() {
        let heroesNav = UINavigationController()
        let favoritesNav = UINavigationController()

        let listHeroesCoordinator = ListHeroesCoordinator(navigationController: heroesNav)
        let favoritesCoordinator = FavoriteHeroesCoordinator(navigationController: favoritesNav)

        self.listHeroesCoordinator = listHeroesCoordinator
        self.favoritesCoordinator = favoritesCoordinator

        listHeroesCoordinator.start()
        favoritesCoordinator.start()

        heroesNav.tabBarItem = UITabBarItem(title: "Heroes", image: UIImage(systemName: "list.bullet"), tag: 0)
        favoritesNav.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star.fill"), tag: 1)

        tabBarController.tabBar.backgroundColor = .white
        tabBarController.viewControllers = [heroesNav, favoritesNav]
    }

    func getRootViewController() -> UIViewController {
        return tabBarController
    }

    func showLoading() {
        guard loadingOverlay == nil else { return }
        guard let view = tabBarController.selectedViewController?.view else { return }

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        overlay.addSubview(spinner)
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
        loadingOverlay = overlay
    }

    func hideLoading() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }

    func showToaster(_ message: String? = nil, toasterType: ToasterType = .error) {
        let message = message ?? NSLocalizedString("some_error", comment: "")
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        tabBarController.present(alertController, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}
