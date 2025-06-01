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
            .receive(on: DispatchQueue.main)
            .sink { heroes in
                if !heroes.isEmpty {
                    XCTAssertEqual(heroes.count, 2)
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
                XCTAssertNotEqual(mock.appliedFilters?.nameStartsWith, "hulk")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchText = "Spi"
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testSortData_SetsOrderAscending() async {
        let mock = MockGetHeroesUseCase()
        mock.mockCharacters = [
            Character(id: 4, name: "Black Widow", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
        ]

        let viewModel = ListHeroesViewModel(getHeroesUseCase: mock)
        let expectation = XCTestExpectation(description: "Initial sort order is ascending")

        viewModel.$heroes
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // Initially, isAscendingSort is false, so orderBy should be "name"
                XCTAssertEqual(mock.appliedFilters?.isAscendingSort, false)
                XCTAssertEqual(mock.appliedFilters?.orderBy, "name")
                XCTAssertFalse(viewModel.isAscendingSort)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchHeroes()
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func testSortData_SetsOrderDescending() async {
        let mock = MockGetHeroesUseCase()
        mock.mockCharacters = [
            Character(id: 4, name: "Black Widow", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
        ]

        let viewModel = ListHeroesViewModel(getHeroesUseCase: mock)
        let expectation = XCTestExpectation(description: "Sort toggled to descending")
        
        XCTAssertFalse(viewModel.isAscendingSort)
        
        viewModel.sortData()
        XCTAssertTrue(viewModel.isAscendingSort)
        
        viewModel.$heroes
            .receive(on: DispatchQueue.main)
            .sink { _ in
                XCTAssertEqual(mock.appliedFilters?.isAscendingSort, true)
                XCTAssertEqual(mock.appliedFilters?.orderBy, "-name")
                XCTAssertTrue(viewModel.isAscendingSort)
                expectation.fulfill()
            }
            .store(in: &cancellables)

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

