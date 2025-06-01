//
//  CharacterDataWrapper.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 28/05/2025.
//

import Foundation

// MARK: - CharacterDataWrapper
struct CharacterDataWrapper: Codable {
    let code: Int?
    let status: String?
    let copyright: String?
    let attributionText: String?
    let attributionHTML: String?
    let data: CharacterDataContainer?
    let etag: String?
}

// MARK: - CharacterDataContainer
struct CharacterDataContainer: Codable {
    let offset: Int?
    let limit: Int?
    let total: Int?
    let count: Int?
    let characters: [Character]?
    
    enum CodingKeys: String, CodingKey {
        case offset
        case limit
        case total
        case count
        case characters = "results"
    }
}

// MARK: - Character
struct Character: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let modified: String?
    let resourceURI: String?
    let urls: [Url]?
    let thumbnail: Image?
    let comics: List?
    let stories: List?
    let event: List?
    let series: List?
}

extension Character {
    var displayDescription: String {
        let description = description?.trimmed() ?? ""
        return description.isEmpty ? "No description available." : description
    }
}

// MARK: - Url
struct Url: Codable, Hashable {
    let type: String?
    let url: String?
}

// MARK: - Image
struct Image: Codable {
    let path: String?
    let `extension`: String?

    enum CodingKeys: String, CodingKey {
        case path
        case `extension` = "extension"
    }
    
    var imageURL: URL? {
        guard let path = path, let `extension` = `extension` else { return nil }
        return URL(string: "\(path)/portrait_small.\(`extension`)")
    }
}

// MARK: - Summary
struct Summary: Codable {
    let resourceURI: String?
    let name: String?
    let type: String?
}

// MARK: - List
struct List: Codable {
    let available: Int?
    let returned: Int?
    let collectionURI: String?
    let items: [Summary]?
}

// MARK: - FilterParameters
struct FilterParameters: Codable {
    var nameStartsWith: String?
    var isAscendingSort: Bool = false
    var offset: Int = 0
    var limit: Int = 20

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let name = nameStartsWith, !name.isEmpty {
            items.append(URLQueryItem(name: "nameStartsWith", value: name))
        }

        if isAscendingSort {
            items.append(URLQueryItem(name: "orderBy", value: orderBy))
        }

        items.append(URLQueryItem(name: "offset", value: "\(offset)"))
        items.append(URLQueryItem(name: "limit", value: "\(limit)"))

        return items
    }
}

extension FilterParameters {
    var orderBy: String {
        isAscendingSort ? "-name" : "name"
    }
}
