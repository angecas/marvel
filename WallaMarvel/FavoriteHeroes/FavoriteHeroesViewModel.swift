//
//  FavoriteHeroesViewModel.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 31/05/2025.
//

import Combine
import Foundation

final class FavoriteHeroesViewModel {
    @Published private(set) var heroes: [Character] = []
    @Published private(set) var error: Bool = false

    private let getHeroesUseCase: GetHeroesUseCaseProtocol

    init(getHeroesUseCase: GetHeroesUseCaseProtocol = GetHeroes()) {
        self.getHeroesUseCase = getHeroesUseCase
    }
    
    func fetchFavoriteHeroes() {
        let favoriteIDs = UserDefaultsHelper.shared.getFavoriteHeroes()
        
        Task { [weak self] in
            guard let self else { return }
            
            var fetchedHeroes: [Character] = []

            for id in favoriteIDs {
                do {
                    let container = try await self.getHeroesUseCase.executeDetails(id: id)
                    if let characters = container?.data?.characters {
                        fetchedHeroes.append(contentsOf: characters)
                    }
                } catch {
                    self.error = true
                }
            }
        self.heroes = fetchedHeroes
        }
    }
    
    func removeFavoriteHero(id: Int) {
        UserDefaultsHelper.shared.removeFavoriteHero(id)
        fetchFavoriteHeroes()
    }
}

