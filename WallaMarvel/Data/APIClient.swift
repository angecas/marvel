import Foundation

protocol APIClientProtocol {
    func getHeroes(filterParameters: FilterParameters) async throws -> CharacterDataWrapper?
    func getHeroDetail(id: Int) async throws -> CharacterDataWrapper?
}

enum APIConfig {
    static let baseURL = "https://gateway.marvel.com/v1/public"

    static func generateAuthQueryItems() -> [URLQueryItem] {
        let ts = String(Int(Date().timeIntervalSince1970))
        let hash = "\(ts)\("188f9a5aa76846d907c41cbea6506e4cc455293f")\("d575c26d5c746f623518e753921ac847")".md5 //private and public

        return [
            URLQueryItem(name: "apikey", value: "d575c26d5c746f623518e753921ac847"), //public
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
