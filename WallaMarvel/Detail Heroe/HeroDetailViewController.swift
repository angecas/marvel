//
//  DetailViewController.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 27/05/2025.
//

import UIKit
import Combine

class HeroDetailViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: DetailViewModel
    private let coordinator: BaseCoordinator
    private var heroes: [Character] = []
    private let id: Int
    
    private lazy var heroDetailsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UIHostingTableViewCell<Character>.self, forCellReuseIdentifier: "HeroDetailHostingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    
    private lazy var noHeroeLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.text = "No heroe found"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(id: Int, viewModel: DetailViewModel = DetailViewModel(), coordinator: BaseCoordinator) {
        self.id = id
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heroDetailsTableView.dataSource = self
        heroDetailsTableView.delegate = self
        setupLayout()
        bindViewModel()
        coordinator.showLoading()
        viewModel.fetchMoreHeroeDetails(id: id)
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(heroDetailsTableView)
        view.addSubview(noHeroeLabel)

        NSLayoutConstraint.activate([
            heroDetailsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroDetailsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroDetailsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            heroDetailsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noHeroeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noHeroeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func bindViewModel() {
        viewModel.$heroeDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heroes in
                self?.heroes = heroes
                self?.heroDetailsTableView.reloadData()
                self?.noHeroeLabel.isHidden = !heroes.isEmpty
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
}

extension HeroDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hero = heroes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroDetailHostingCell", for: indexPath) as! UIHostingTableViewCell<Character>
        cell.cellType = .heroesDetailsList
        cell.data = hero
        cell.uiTableViewCell()
        return cell
    }
}
