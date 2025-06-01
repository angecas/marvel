//
//  MockUserDefaults.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 01/06/2025.
//

import XCTest
@testable import WallaMarvel

class MockUserDefaults: UserDefaultsProtocol {
    private var storage = [String: Any]()

    func array(forKey defaultName: String) -> [Any]? {
        return storage[defaultName] as? [Any]
    }

    func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    func setFavoriteHeroes(_ heroes: [Int]) {
        set(heroes, forKey: "favoriteHeroes")
    }
}
