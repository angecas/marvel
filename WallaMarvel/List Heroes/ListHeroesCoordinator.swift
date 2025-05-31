//
//  ListHeroesCoordinator.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 26/05/2025.
//

import UIKit

protocol ListHeroesCoordinatorDelegate: AnyObject {
    func didTapSearch()
    func didTapSort()
}

final class ListHeroesCoordinator: BaseCoordinator {
    weak var delegate: ListHeroesCoordinatorDelegate?
    private var loadingOverlay: UIView?
    private var searchBarButtonItem: UIBarButtonItem?
    private var sortBarButtonItem: UIBarButtonItem?

    
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
    }

    override func start() {
        let viewController = ListHeroesViewController(coordinator: self)
        viewController.title = NSLocalizedString("list_heroes_title", comment: "")

        let searchItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(didTapSearch)
        )
        self.searchBarButtonItem = searchItem
        viewController.navigationItem.rightBarButtonItem = searchItem
        
        let sortItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: #selector(didTapFilter)
        )
        
        self.sortBarButtonItem = sortItem
        viewController.navigationItem.leftBarButtonItem = sortItem

        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHeroDetail(hero: Character) {
        guard let heroId = hero.id else { return }
        let heroDetailViewController = HeroDetailViewController(id: heroId, coordinator: self)
        heroDetailViewController.title = hero.name ?? "No name"
        navigationController.pushViewController(heroDetailViewController, animated: true)
    }
    
    @objc private func didTapSearch() {
        delegate?.didTapSearch()
    }
    
    @objc private func didTapFilter() {
        delegate?.didTapSort()
    }
    
    func updateSearchIcon(hasActiveSearch: Bool) {
        let imageName = hasActiveSearch ? "exclamationmark.magnifyingglass" : "magnifyingglass"
        searchBarButtonItem?.image = UIImage(systemName: imageName)
    }
    
    func updateSortIcon(isAscending: Bool) {
        guard let cgImage = UIImage(systemName: "line.3.horizontal.decrease")?.cgImage
            else { return }
        
        let image = isAscending ? UIImage(cgImage: cgImage, scale: 2, orientation: .down) : UIImage(cgImage: cgImage, scale: 2, orientation: .up)
        
        sortBarButtonItem?.image = image
    }
}
