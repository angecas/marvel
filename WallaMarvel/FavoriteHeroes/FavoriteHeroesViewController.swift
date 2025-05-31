//
//  FavoriteHeroesViewController.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 31/05/2025.
//

import UIKit
import SwiftUI
import Combine

final class FavoriteHeroesViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: FavoriteHeroesViewModel
    private let coordinator: FavoriteHeroesCoordinator
    private var heroes: [Character] = []
    private let refreshControl = UIRefreshControl()

    private lazy var heroesTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UIHostingTableViewCell<Character>.self, forCellReuseIdentifier: "HeroHostingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var noFavoriteHeroesLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.text = "No favorite heroes"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: FavoriteHeroesViewModel = FavoriteHeroesViewModel(), coordinator: FavoriteHeroesCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroesTableView.dataSource = self
        heroesTableView.delegate = self
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        heroesTableView.refreshControl = refreshControl

        setupLayout()
        bindViewModel()
        DispatchQueue.main.async {
            self.coordinator.showLoading()
        }
        viewModel.fetchFavoriteHeroes()
    }
    
    private func setupLayout() {
        view.addSubview(heroesTableView)
        view.addSubview(noFavoriteHeroesLabel)

        NSLayoutConstraint.activate([
            heroesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            heroesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noFavoriteHeroesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noFavoriteHeroesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func bindViewModel() {
        viewModel.$heroes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heroes in
                self?.heroes = heroes
                self?.heroesTableView.reloadData()
                self?.noFavoriteHeroesLabel.isHidden = !heroes.isEmpty
                self?.refreshControl.endRefreshing()
                self?.coordinator.hideLoading()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if error == true {
                    self?.coordinator.showToaster()
                    self?.coordinator.hideLoading()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func didPullToRefresh() {
        viewModel.fetchFavoriteHeroes()
    }
}

extension FavoriteHeroesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hero = heroes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroHostingCell", for: indexPath) as! UIHostingTableViewCell<Character>
        cell.data = hero
        cell.uiTableViewCell()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHero = heroes[indexPath.row]
        coordinator.showHeroDetail(hero: selectedHero)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let heroID = self.heroes[indexPath.row].id else { return nil }

        let action: UIContextualAction
        
        action = UIContextualAction(style: .normal, title: "Remove Favorite") { [weak self] action, view, completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }

            viewModel.removeFavoriteHero(id: heroID)
            DispatchQueue.main.async {
                self.coordinator.showToaster("Hero removed from favorites.", toasterType: .informative)
            }
            completionHandler(true)
        }
        
        action.backgroundColor = .systemGray

        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
