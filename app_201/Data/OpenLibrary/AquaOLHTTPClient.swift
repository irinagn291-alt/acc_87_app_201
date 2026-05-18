import Foundation

protocol AquaOLHTTPClient: Sendable {
    func searchByTitle(_ title: String, limit: Int, offset: Int) async throws -> AquaOLSearchResponse
    func searchByQuery(_ query: String, limit: Int, offset: Int) async throws -> AquaOLSearchResponse
    func fetchWork(workKey: String) async throws -> AquaOLWork
    func fetchSubject(slug: String, limit: Int, offset: Int) async throws -> AquaOLSubjectResponse
}

final class AquaURLSessionOLClient: AquaOLHTTPClient, @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    private func get<T: Decodable>(_ url: URL?, as type: T.Type) async throws -> T {
        guard let url else { throw AquaNetError.invalidURL }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw AquaNetError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw AquaNetError.httpStatus(http.statusCode) }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AquaNetError.decoding(error)
        }
    }

    func searchByTitle(_ title: String, limit: Int, offset: Int) async throws -> AquaOLSearchResponse {
        try await get(AquaOLEndpoint.searchTitle(title, limit: limit, offset: offset), as: AquaOLSearchResponse.self)
    }

    func searchByQuery(_ query: String, limit: Int, offset: Int) async throws -> AquaOLSearchResponse {
        try await get(AquaOLEndpoint.searchQuery(query, limit: limit, offset: offset), as: AquaOLSearchResponse.self)
    }

    func fetchWork(workKey: String) async throws -> AquaOLWork {
        try await get(AquaOLEndpoint.work(workKey), as: AquaOLWork.self)
    }

    func fetchSubject(slug: String, limit: Int, offset: Int) async throws -> AquaOLSubjectResponse {
        try await get(AquaOLEndpoint.subject(slug, limit: limit, offset: offset), as: AquaOLSubjectResponse.self)
    }
}
