import XCTest
import Combine
@testable import WallaMarvel

final class DetailViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testFetchHeroeDetails_diffrentId() async {
        // Given
        let expectedCharacters: [Character] = [
            Character(id: 1, name: "Iron Man", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil)
        ]

        let mockUseCase = MockGetHeroesUseCase()
        mockUseCase.mockCharacters = expectedCharacters

        let viewModel = DetailViewModel(getHeroesUseCase: mockUseCase)

        let detailExpectation = XCTestExpectation(description: "Incorrect characters received")
                
        viewModel.$heroeDetail
            .dropFirst()
            .sink { characters in
                XCTAssertNotEqual(characters.map { $0.id }, expectedCharacters.map { $0.id })
                detailExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchMoreHeroeDetails(id: 9)

        // Then
        await fulfillment(of: [detailExpectation], timeout: 1.0)
    }
    
    func testFetchHeroeDetails_SameId() async {
        // Given
        let expectedCharacters: [Character] = [
            Character(id: 1, name: "Iron Man", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil)
        ]

        let mockUseCase = MockGetHeroesUseCase()
        mockUseCase.mockCharacters = expectedCharacters

        let viewModel = DetailViewModel(getHeroesUseCase: mockUseCase)

        let detailExpectation = XCTestExpectation(description: "Incorrect characters received")
                
        viewModel.$heroeDetail
            .dropFirst()
            .sink { characters in
                XCTAssertEqual(characters.map { $0.id }, expectedCharacters.map { $0.id })
                detailExpectation.fulfill()
            }
            .store(in: &cancellables)
        

        // When
        viewModel.fetchMoreHeroeDetails(id: 1)

        // Then
        await fulfillment(of: [detailExpectation], timeout: 1.0)
    }
    
    func testFetchHeroeDetails_Fails() async {
        // Given
        let expectedCharacters: [Character] = [
            Character(id: 1, name: "Iron Man", description: "A hero", modified: nil, resourceURI: nil, urls: nil, thumbnail: nil, comics: nil, stories: nil, event: nil, series: nil)
        ]

        let mockUseCase = MockGetHeroesUseCase()
        mockUseCase.shouldReturnError = true
        mockUseCase.mockCharacters = expectedCharacters

        let viewModel = DetailViewModel(getHeroesUseCase: mockUseCase)

        let errorExpectation = XCTestExpectation(description: "Error triggered")

        viewModel.$error
            .dropFirst()
            .sink { hasError in
                XCTAssertTrue(hasError)
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchMoreHeroeDetails(id: 1)

        // Then
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
}
