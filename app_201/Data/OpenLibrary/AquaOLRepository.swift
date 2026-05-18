import Foundation

@MainActor
final class AquaOLRepositoryImpl: AquaSearchRepository {
    private let client: AquaOLHTTPClient

    init(client: AquaOLHTTPClient) {
        self.client = client
    }

    func searchByTitle(_ title: String, limit: Int, offset: Int) async throws -> [AquaSearchHit] {
        AquaOLMapper.searchHits(from: try await client.searchByTitle(title, limit: limit, offset: offset))
    }

    func searchByQuery(_ query: String, limit: Int, offset: Int) async throws -> [AquaSearchHit] {
        AquaOLMapper.searchHits(from: try await client.searchByQuery(query, limit: limit, offset: offset))
    }

    func workDetail(workKey: String, fallbackAuthors: [String]) async throws -> AquaWorkDetail {
        let dto = try await client.fetchWork(workKey: workKey)
        guard let detail = AquaOLMapper.workDetail(from: dto, fallbackAuthors: fallbackAuthors) else {
            throw AquaNetError.noData
        }
        return detail
    }

    func subjectBooks(slug: String, limit: Int, offset: Int) async throws -> [AquaSubjectBook] {
        AquaOLMapper.subjectBooks(from: try await client.fetchSubject(slug: slug, limit: limit, offset: offset))
    }
}
