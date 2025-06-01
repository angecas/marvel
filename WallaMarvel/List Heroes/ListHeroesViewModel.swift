//
//  ListHeroesViewModel.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 26/05/2025.
//
import Combine
import Foundation
final class ListHeroesViewModel {
    @Published private(set) var heroes: [Character] = []
    @Published private(set) var filteredHeroes: [Character] = []
    @Published private(set) var error: Bool = false
    @Published var searchText: String = ""
    
    private(set) var isAscendingSort: Bool = false
    private(set) var isLoading = false
    private(set) var hasMoreData = true

    private var filterParameters: FilterParameters = FilterParameters() {
        didSet {
            fetchPage(filterParameters: filterParameters)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var currentRequestID = 0
    private var currentPage = 0
    private var heroesTotalCount = 0
    private let getHeroesUseCase: GetHeroesUseCaseProtocol

    init(getHeroesUseCase: GetHeroesUseCaseProtocol = GetHeroes()) {
        self.getHeroesUseCase = getHeroesUseCase

        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.searchFreeText(text)
            }
            .store(in: &cancellables)
    }

    func fetchHeroes() {
        currentPage = 0
        hasMoreData = true
        heroes = []
        filteredHeroes = []

        filterParameters = FilterParameters(
            nameStartsWith: filterParameters.nameStartsWith,
            isAscendingSort: filterParameters.isAscendingSort,
            offset: 0,
            limit: 20
        )
    }

    func fetchMoreHeroes() {
        guard !isLoading, hasMoreData else { return }
        currentPage += 1

        var params = filterParameters
        params.offset = currentPage * params.limit
        filterParameters = params
    }

    private func fetchPage(filterParameters: FilterParameters) {
        isLoading = true
        currentRequestID += 1
        let requestID = currentRequestID

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let container = try await self.getHeroesUseCase.execute(filterParameters: filterParameters)
                let newHeroes = container?.data?.characters ?? []

                guard requestID == self.currentRequestID else { return }

                if filterParameters.offset == 0 {
                    self.heroes = newHeroes
                    self.filteredHeroes = newHeroes
                    self.heroesTotalCount = container?.data?.total ?? 0
                } else {
                    self.heroes += newHeroes
                    self.filteredHeroes += newHeroes
                }

                self.hasMoreData = self.heroes.count < self.heroesTotalCount
                
                self.isLoading = false
            } catch {
                guard requestID == self.currentRequestID else { return }
                self.error = true
                self.isLoading = false
            }
        }
    }

    func sortData() {
        isAscendingSort.toggle()
        var params = filterParameters
        params.isAscendingSort = isAscendingSort
        params.offset = 0
        currentPage = 0
        filterParameters = params
    }

    func searchFreeText(_ text: String) {
        var params = filterParameters
        params.nameStartsWith = text
        params.offset = 0
        currentPage = 0
        filterParameters = params
    }
}
