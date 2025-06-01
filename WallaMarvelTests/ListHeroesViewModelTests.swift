//
//  ListHeroesViewModelTests.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 01/06/2025.
//

import XCTest
import Combine
@testable import WallaMarvel

final class ListHeroesViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testFetchHeroesLoadsData() async {
        let mock = MockGetHeroesUseCase()
        mock.mockCharacters = [
            Character(id: 1, name: "Iron Man", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
            Character(id: 2, name: "Hulk", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
        ]

        let viewModel = ListHeroesViewModel(getHeroesUseCase: mock)
        let expectation = XCTestExpectation(description: "Heroes loaded")

        viewModel.$heroes
            .dropFirst()
            .sink { heroes in
                if heroes.count == 2 {
                    XCTAssertEqual(heroes.first?.name, "Iron Man")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchHeroes()

        await fulfillment(of: [expectation], timeout: 2)
    }

    func testSearchFreeTextTriggersFilterUpdate() async {
        let mock = MockGetHeroesUseCase()
        mock.mockCharacters = [
            Character(id: 3, name: "Spiderman", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
        ]

        let viewModel = ListHeroesViewModel(getHeroesUseCase: mock)
        let expectation = XCTestExpectation(description: "Search triggered")

        viewModel.$heroes
            .dropFirst()
            .sink { _ in
                XCTAssertEqual(mock.appliedFilters?.nameStartsWith, "Spi")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchText = "Spi"
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testSortTogglesOrder() async {
        let mock = MockGetHeroesUseCase()
        mock.mockCharacters = [
            Character(id: 4, name: "Black Widow", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
        ]

        let viewModel = ListHeroesViewModel(getHeroesUseCase: mock)
        let expectation = XCTestExpectation(description: "Sorted triggered")

        var triggeredSort = false

        viewModel.$heroes
            .dropFirst()
            .sink { _ in
                if !triggeredSort {
                    triggeredSort = true
                    viewModel.sortData()
                } else {
                    XCTAssertEqual(mock.appliedFilters?.orderBy, "-name")
                    XCTAssertTrue(viewModel.isAscendingSort)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchHeroes()
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testErrorFlagIsSetOnFailure() async {
        let mock = MockGetHeroesUseCase()
        mock.shouldReturnError = true

        let viewModel = ListHeroesViewModel(getHeroesUseCase: mock)
        let expectation = XCTestExpectation(description: "Error flag triggered")

        viewModel.$error
            .dropFirst()
            .sink { error in
                XCTAssertTrue(error)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchHeroes()
        await fulfillment(of: [expectation], timeout: 2)
    }
}

