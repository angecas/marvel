//
//  FavoriteHeroesCoordinator.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 27/05/2025.
//

import UIKit

final class FavoriteHeroesCoordinator: BaseCoordinator {
    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewController = FavoriteHeroesViewController(coordinator: self)
        viewController.title = "Favorite Heroes"
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHeroDetail(hero: Character) {
        guard let heroId = hero.id else { return }
        let heroDetailViewController = HeroDetailViewController(id: heroId, coordinator: self)
        heroDetailViewController.title = hero.name ?? "No name"
        navigationController.pushViewController(heroDetailViewController, animated: true)
    }
}
