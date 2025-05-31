import UIKit
import SwiftUI
import Combine

final class ListHeroesViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: ListHeroesViewModel
    private let coordinator: ListHeroesCoordinator
    private var heroes: [Character] = []
    private var searchBarHeightConstraint = NSLayoutConstraint()

    private var isSearching: Bool = false {
        didSet {
            searchBarHeightConstraint.constant = isSearching ? 44 : 0
            searchBar.isHidden = !isSearching
            view.layoutIfNeeded()
        }
    }

    private var searchText: String = "" {
        didSet {
                self.viewModel.searchFreeText(self.searchText)
        }
    }
    private lazy var searchBar: UIView = {
        let searchTextBinding = Binding<String>(
            get: { [weak self] in self?.searchText ?? "" },
            set: { [weak self] newValue in self?.searchText = newValue }
        )
        let searchView = SearchBarView(searchText: searchTextBinding)
        let hostingController = UIHostingController(rootView: searchView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.isHidden = true
        return hostingController.view
    }()

    private lazy var heroesTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UIHostingTableViewCell<Character>.self, forCellReuseIdentifier: "HeroHostingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private lazy var noHeroesLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.text = "No heroes found"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: ListHeroesViewModel = ListHeroesViewModel(), coordinator: ListHeroesCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.coordinator.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        heroesTableView.dataSource = self
        heroesTableView.delegate = self
        setupLayout()
        DispatchQueue.main.async {
            self.coordinator.showLoading()
        }
        viewModel.fetchHeroes()
        
        bindViewModel()
    }

    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(heroesTableView)
        view.addSubview(noHeroesLabel)

        searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            searchBarHeightConstraint,
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            heroesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            heroesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noHeroesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noHeroesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.$filteredHeroes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] heroes in
                let hasSearchText = !(self?.searchText.trimmed().isEmpty ?? true)
                DispatchQueue.main.async {
                    self?.coordinator.updateSearchIcon(hasActiveSearch: hasSearchText)
                    self?.coordinator.updateSortIcon(isAscending: self?.viewModel.isAscendingSort ?? false)
                }
                self?.heroes = heroes
                self?.heroesTableView.reloadData()
                self?.noHeroesLabel.isHidden = !heroes.isEmpty
                DispatchQueue.main.async {
                    self?.coordinator.hideLoading()
                }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height {
            DispatchQueue.main.async {
                self.coordinator.showLoading()
            }
            viewModel.fetchMoreHeroes()
        }
    }
}

extension ListHeroesViewController: UITableViewDataSource, UITableViewDelegate {
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
        let isFavoriteHero = UserDefaultsHelper.shared.isFavoriteHero(heroID)

        let action: UIContextualAction

        if isFavoriteHero {
            action = UIContextualAction(style: .normal, title: "Remove Favorite") { [weak self] action, view, completionHandler in
                guard let self = self else {
                    completionHandler(false)
                    return
                }

                UserDefaultsHelper.shared.removeFavoriteHero(heroID)
                self.coordinator.showToaster("Hero removed from favorites.", toasterType: .informative)
                completionHandler(true)
            }
            action.backgroundColor = .systemGray
        } else {
            action = UIContextualAction(style: .normal, title: "Add Favorite") { [weak self] action, view, completionHandler in
                guard let self = self else {
                    completionHandler(false)
                    return
                }

                let saved = UserDefaultsHelper.shared.saveFavoriteHero(heroID)
                if saved {
                    self.coordinator.showToaster("Successfully saved hero.", toasterType: .informative)
                } else {
                    self.coordinator.showToaster("Cannot add more than 5 favorites.", toasterType: .informative)
                }
                completionHandler(true)
            }
            action.backgroundColor = .systemRed
        }

        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

extension ListHeroesViewController: ListHeroesCoordinatorDelegate {
    func didTapSearch() {
        isSearching.toggle()
    }

    func didTapSort() {
        DispatchQueue.main.async {
            self.coordinator.showLoading()
            self.coordinator.updateSortIcon(isAscending: self.viewModel.isAscendingSort)
        }
        viewModel.sortData()
    }
}
