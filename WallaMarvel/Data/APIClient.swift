import Foundation

protocol APIClientProtocol {
    func getHeroes(filterParameters: FilterParameters) async throws -> CharacterDataWrapper?
    func getHeroDetail(id: Int) async throws -> CharacterDataWrapper?
}

enum APIConfig {
    static let baseURL = "https://gateway.marvel.com/v1/public"

    static func generateAuthQueryItems() -> [URLQueryItem] {
        let ts = String(Int(Date().timeIntervalSince1970))
        guard
            let privateKey = Bundle.main.infoDictionary?["API_PRIVATE_KEY"] as? String,
            let publicKey = Bundle.main.infoDictionary?["API_PUBLIC_KEY"] as? String
        else {
            fatalError("Missing API keys in Info.plist")
        }

        let hash = "\(ts)\(privateKey)\(publicKey)".md5

        return [
            URLQueryItem(name: "apikey", value: publicKey),
            URLQueryItem(name: "ts", value: ts),
            URLQueryItem(name: "hash", value: hash)
        ]
    }
}

final class APIClient: APIClientProtocol {

      private func performRequest(from components: URLComponents) async throws -> CharacterDataWrapper {
          guard let url = components.url else {
              throw URLError(.badURL)
          }

          let request = URLRequest(url: url)
          let (data, response) = try await URLSession.shared.data(for: request)

          guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
              throw URLError(.badServerResponse)
          }

          return try JSONDecoder().decode(CharacterDataWrapper.self, from: data)
      }

      // MARK: - API Methods
    
    func getHeroes(filterParameters: FilterParameters) async throws -> CharacterDataWrapper? {
        if var components = URLComponents(string: "\(APIConfig.baseURL)/characters") {
            var queryItems = filterParameters.toQueryItems()
            queryItems.append(contentsOf: APIConfig.generateAuthQueryItems())
            components.queryItems = queryItems

            return try await performRequest(from: components)
        }
        return nil
    }

    func getHeroDetail(id: Int) async throws -> CharacterDataWrapper? {
        if var components = URLComponents(string: "\(APIConfig.baseURL)/characters/\(id)") {
            components.queryItems = APIConfig.generateAuthQueryItems()
            return try await performRequest(from: components)
        }
        return nil
    }
}
