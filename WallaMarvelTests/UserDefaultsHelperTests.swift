//
//  UserDefaultsHelperTests.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 01/06/2025.
//


import XCTest
@testable import WallaMarvel

final class UserDefaultsHelperTests: XCTestCase {

    func testSaveFavoriteHeroAddsHero() {
        let mockDefaults = MockUserDefaults()
        let helper = UserDefaultsHelper(defaults: mockDefaults)

        XCTAssertEqual(helper.getFavoriteHeroes(), [])
        XCTAssertEqual(helper.getFavoriteHeroes().count, 0)
        
        let saved = helper.saveFavoriteHero(1)
        XCTAssertTrue(saved)
        XCTAssertEqual(helper.getFavoriteHeroes(), [1])
        XCTAssertEqual(helper.getFavoriteHeroes().count, 1)

        XCTAssertFalse(helper.saveFavoriteHero(1))
        XCTAssertEqual(helper.getFavoriteHeroes(), [1])
        XCTAssertEqual(helper.getFavoriteHeroes().count, 1)
    }

    func testSaveFavoriteHeroLimitsToMaxFavorites() {
        let mockDefaults = MockUserDefaults()
        let helper = UserDefaultsHelper(defaults: mockDefaults)

        for heroID in 1...5 {
            XCTAssertTrue(helper.saveFavoriteHero(heroID))
        }

        XCTAssertEqual(helper.getFavoriteHeroes().count, 5)
        XCTAssertFalse(helper.saveFavoriteHero(1))
        XCTAssertEqual(helper.getFavoriteHeroes().count, 5)
    }

    func testRemoveFavoriteHero() {
        let mockDefaults = MockUserDefaults()
        let helper = UserDefaultsHelper(defaults: mockDefaults)

        _ = helper.saveFavoriteHero(1)
        _ = helper.saveFavoriteHero(2)
        XCTAssertEqual(helper.getFavoriteHeroes(), [2, 1])
        XCTAssertEqual(helper.getFavoriteHeroes().count, 2)

        helper.removeFavoriteHero(2)
        XCTAssertEqual(helper.getFavoriteHeroes(), [1])
        XCTAssertEqual(helper.getFavoriteHeroes().count, 1)

        helper.removeFavoriteHero(99)
        XCTAssertEqual(helper.getFavoriteHeroes(), [1])
        XCTAssertEqual(helper.getFavoriteHeroes().count, 1)
    }

    func testIsFavoriteHero() {
        let mockDefaults = MockUserDefaults()
        let helper = UserDefaultsHelper(defaults: mockDefaults)

        XCTAssertFalse(helper.isFavoriteHero(1))
        _ = helper.saveFavoriteHero(1)
        XCTAssertTrue(helper.isFavoriteHero(1))
        helper.removeFavoriteHero(1)
        XCTAssertFalse(helper.isFavoriteHero(1))
    }
}
