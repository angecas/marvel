import XCTest
import Combine
@testable import WallaMarvel

final class DetailViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testFetchHeroeDetails_Success() async {
        // Given
        let expectedCharacters: [Character] = [
            Character(id: 1, name: "Iron Man", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil),
            Character(id: 2, name: "Thor", description: "God of Thunder", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil)
        ]

        let mockUseCase = MockGetHeroesUseCase()
        mockUseCase.mockCharacters = expectedCharacters

        let viewModel = DetailViewModel(getHeroesUseCase: mockUseCase)

        let expectation = XCTestExpectation(description: "Characters loaded")

        viewModel.$heroeDetail
            .dropFirst()
            .sink { characters in
                XCTAssertEqual(characters.map { $0.id }, expectedCharacters.map { $0.id })
                XCTAssertEqual(characters.map { $0.name }, expectedCharacters.map { $0.name })
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchMoreHeroeDetails(id: 101)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.error)
    }

    func testFetchHeroeDetails_Failure() async {
        // Given
        let mockUseCase = MockGetHeroesUseCase()
        mockUseCase.shouldReturnError = true

        let viewModel = DetailViewModel(getHeroesUseCase: mockUseCase)

        let expectation = XCTestExpectation(description: "Error flag set")

        viewModel.$error
            .dropFirst()
            .sink { hasError in
                XCTAssertTrue(hasError)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchMoreHeroeDetails(id: 999)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
