import Foundation

protocol MarvelRepositoryProtocol {
    func getHeroes(filterParameters: FilterParameters) async throws -> CharacterDataWrapper?
    func getHeroesDetail(id: Int) async throws -> CharacterDataWrapper?
}

final class MarvelRepository: MarvelRepositoryProtocol {
    private let dataSource: MarvelDataSourceProtocol
    
    init(dataSource: MarvelDataSourceProtocol = MarvelDataSource()) {
        self.dataSource = dataSource
    }
    
    func getHeroes(filterParameters: FilterParameters) async -> CharacterDataWrapper? {
        do {
            return try await dataSource.getHeroes(filterParameters: filterParameters)
        } catch {
            return nil
        }
    }
    
    func getHeroesDetail(id: Int) async -> CharacterDataWrapper? {
        do {
            return try await dataSource.getHeroesDetail(id: id)
        } catch {
            return nil
        }
    }
}
