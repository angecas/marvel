import Foundation

protocol MarvelDataSourceProtocol {
    func getHeroes(filterParameters: FilterParameters) async throws -> CharacterDataWrapper?
    func getHeroesDetail(id: Int) async throws -> CharacterDataWrapper?
}

final class MarvelDataSource: MarvelDataSourceProtocol {

    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getHeroes(filterParameters: FilterParameters) async throws -> CharacterDataWrapper? {
        do {
            return try await apiClient.getHeroes(filterParameters: filterParameters)
        } catch {
            return nil
        }
    }
    
    func getHeroesDetail(id: Int) async throws -> CharacterDataWrapper? {
        do {
            return try await apiClient.getHeroDetail(id: id)
        } catch {
            return nil
        }
    }
}
