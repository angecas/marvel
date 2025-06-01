//
//  MockGetHeroesUseCase.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 01/06/2025.
//
import XCTest
import Combine
@testable import WallaMarvel

final class MockGetHeroesUseCase: GetHeroesUseCaseProtocol {
    var shouldReturnError = false
    var mockCharacters: [Character] = []
    var appliedFilters: FilterParameters?

    func execute(filterParameters: FilterParameters) async throws -> CharacterDataWrapper? {
        appliedFilters = filterParameters

        if shouldReturnError {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }

        let container = CharacterDataContainer(
            offset: filterParameters.offset,
            limit: filterParameters.limit,
            total: mockCharacters.count,
            count: mockCharacters.count,
            characters: mockCharacters
        )

        return CharacterDataWrapper(
            code: 200,
            status: "Ok",
            copyright: nil,
            attributionText: nil,
            attributionHTML: nil,
            data: container,
            etag: nil
        )
    }
    
    func executeDetails(id: Int) async throws -> CharacterDataWrapper? {
        if shouldReturnError {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }

        let container = CharacterDataContainer(
            offset: 0,
            limit: 20,
            total: mockCharacters.count,
            count: mockCharacters.count,
            characters: mockCharacters
        )

        return CharacterDataWrapper(
            code: 200,
            status: "Ok",
            copyright: nil,
            attributionText: nil,
            attributionHTML: nil,
            data: container,
            etag: nil
        )
    }
}
