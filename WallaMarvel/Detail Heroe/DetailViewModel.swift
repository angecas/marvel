//
//  DetailViewModel.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 27/05/2025.
//

import Combine
import Foundation

final class DetailViewModel {
    @Published private(set) var heroeDetail: [Character] = []
    @Published private(set) var error: Bool = false

    private let getHeroesUseCase: GetHeroesUseCaseProtocol

    init(getHeroesUseCase: GetHeroesUseCaseProtocol = GetHeroes()) {
        self.getHeroesUseCase = getHeroesUseCase
    }
    
    func fetchMoreHeroeDetails(id: Int) {
        Task { [weak self] in
            do {
                let container = try await self?.getHeroesUseCase.executeDetails(id: id)
                self?.heroeDetail = container?.data?.characters ?? []
            } catch {
                self?.error = true
            }
        }

    }
}

