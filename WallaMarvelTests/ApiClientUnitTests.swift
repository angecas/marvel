//
//  ApiClientUnitTests.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 01/06/2025.
//

import XCTest
@testable import WallaMarvel

final class APIClientTests: XCTestCase {

    override class func setUp() {
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override class func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    func testGetHeroes_Path() async throws {
        // Arrange
        let expectedNameStart = "Spider"
        let expectedPath = "/v1/public/characters"

        let filter = FilterParameters(nameStartsWith: expectedNameStart)
        let client = APIClient()

        var requestedURL: URL?

        MockURLProtocol.requestHandler = { request in
            requestedURL = request.url
            let dummyData = try JSONEncoder().encode(CharacterDataWrapper(code: 200, status: nil, copyright: nil, attributionText: nil,
                                                                          attributionHTML: nil, data: nil, etag: nil))
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, dummyData)
        }

        // Act
        _ = try await client.getHeroes(filterParameters: filter)

        // Assert
        XCTAssertNotNil(requestedURL)
        XCTAssertTrue(requestedURL?.path == expectedPath)
        XCTAssertTrue(requestedURL?.query?.contains("nameStartsWith=Spider") ?? false)
        XCTAssertTrue(requestedURL?.query?.contains("apikey=") ?? false)
        XCTAssertTrue(requestedURL?.query?.contains("ts=") ?? false)
        XCTAssertTrue(requestedURL?.query?.contains("hash=") ?? false)
    }

    func testGetHeroDetail_Path() async throws {
        // Arrange
        let heroId = 123
        let expectedPath = "/v1/public/characters/\(heroId)"

        let client = APIClient()

        var requestedURL: URL?

        MockURLProtocol.requestHandler = { request in
            requestedURL = request.url
            let dummyData = try JSONEncoder().encode(CharacterDataWrapper(code: 200, status: nil, copyright: nil,
                                                                          attributionText: nil, attributionHTML: nil,
                                                                          data: nil, etag: nil))
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, dummyData)
        }

        // Act
        _ = try await client.getHeroDetail(id: heroId)

        // Assert
        XCTAssertNotNil(requestedURL)
        XCTAssertTrue(requestedURL?.path == expectedPath)
        XCTAssertTrue(requestedURL?.query?.contains("apikey=") ?? false)
        XCTAssertTrue(requestedURL?.query?.contains("ts=") ?? false)
        XCTAssertTrue(requestedURL?.query?.contains("hash=") ?? false)
    }
}
