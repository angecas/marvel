import Foundation

protocol GetHeroesUseCaseProtocol {
    func execute(filterParameters: FilterParameters) async throws -> CharacterDataWrapper?
    func executeDetails(id: Int) async throws -> CharacterDataWrapper?
}

struct GetHeroes: GetHeroesUseCaseProtocol {
    func executeDetails(id: Int) async throws -> CharacterDataWrapper? {
        try await repository.getHeroesDetail(id: id)
    }
    
    func execute(filterParameters: FilterParameters) async throws -> CharacterDataWrapper? {
        try await repository.getHeroes(filterParameters: filterParameters)
    }
    
    private let repository: MarvelRepositoryProtocol
    
    init(repository: MarvelRepositoryProtocol = MarvelRepository()) {
        self.repository = repository
    }
    
}
