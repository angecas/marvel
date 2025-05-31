//
//  FavoritesManager.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 31/05/2025.
//


import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let defaults = UserDefaults.standard
    private let favoritesKey = "favorites"
    private let maxFavorites = 5

    private init() {}

    /// Retrieves the current list of favorite items
    func getFavorites() -> [String] {
        return defaults.stringArray(forKey: favoritesKey) ?? []
    }

    /// Adds a new item to favorites (moves to front if already exists)
    func addFavorite(_ item: String) {
        var favorites = getFavorites()
        
        // Remove item if it's already in the list
        favorites.removeAll { $0 == item }

        // Add to the top
        favorites.insert(item, at: 0)

        // Keep only the last `maxFavorites`
        if favorites.count > maxFavorites {
            favorites = Array(favorites.prefix(maxFavorites))
        }

        defaults.set(favorites, forKey: favoritesKey)
    }

    /// Removes an item from favorites
    func removeFavorite(_ item: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0 == item }
        defaults.set(favorites, forKey: favoritesKey)
    }

    /// Checks if an item is already a favorite
    func isFavorite(_ item: String) -> Bool {
        return getFavorites().contains(item)
    }

    /// Clears all favorites (optional utility)
    func clearFavorites() {
        defaults.removeObject(forKey: favoritesKey)
    }
}
