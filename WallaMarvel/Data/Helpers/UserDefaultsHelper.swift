//
//  UserDefaultsHelper.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 31/05/2025.
//

import Foundation
import Foundation
protocol UserDefaultsProtocol {
    func array(forKey defaultName: String) -> [Any]?
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()

    private let defaults: UserDefaultsProtocol
    private let favoritesKey = "favoriteHeroes"
    private let maxFavorites = 5

    init(defaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.defaults = defaults
    }

    func saveFavoriteHero(_ hero: Int) -> Bool {
        var favorites = defaults.array(forKey: favoritesKey) as? [Int] ?? []
        
        if !isFavoriteHero(hero) && favorites.count < maxFavorites {
            favorites.insert(hero, at: 0)
            defaults.set(favorites, forKey: favoritesKey)
            return true
        }
        return false
    }

    func getFavoriteHeroes() -> [Int] {
        return defaults.array(forKey: favoritesKey) as? [Int] ?? []
    }

    func removeFavoriteHero(_ hero: Int) {
        var favorites = getFavoriteHeroes()
        favorites.removeAll { $0 == hero }
        defaults.set(favorites, forKey: favoritesKey)
    }

    func isFavoriteHero(_ hero: Int) -> Bool {
        return getFavoriteHeroes().contains(hero)
    }
}
