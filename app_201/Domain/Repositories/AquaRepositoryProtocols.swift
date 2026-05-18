import Foundation

struct AquaPrefsSnapshot: Equatable, Sendable {
    var hasCompletedOnboarding: Bool
    var selectedGenres: [String]
    var preferredTheme: AquaDisplayTheme
    var shelfLayout: AquaShelfLayout
    var readingGoals: [String]
}

@MainActor
protocol AquaPrefsRepository {
    func load() throws -> AquaPrefsSnapshot
    func save(_ snapshot: AquaPrefsSnapshot) throws
}

@MainActor
protocol AquaBookRepository {
    func allBooks() throws -> [AquaBookEntry]
    func book(id: UUID) throws -> AquaBookEntry?
    func upsert(_ book: AquaBookEntry) throws
    func delete(id: UUID) throws
    func clearAll() throws
}

@MainActor
protocol AquaMoodListRepository {
    func allLists() throws -> [AquaMoodListRow]
    func saveList(title: String, moodKey: String, books: [AquaSearchHit]) throws
    func deleteList(id: UUID) throws
}

@MainActor
protocol AquaProgressRepository {
    func logDelta(bookId: UUID, delta: Int) throws
    func events(for bookId: UUID) throws -> [AquaProgressEvent]
    func allEvents() throws -> [AquaProgressEvent]
}

@MainActor
protocol AquaSearchRepository {
    func searchByTitle(_ title: String, limit: Int, offset: Int) async throws -> [AquaSearchHit]
    func searchByQuery(_ query: String, limit: Int, offset: Int) async throws -> [AquaSearchHit]
    func workDetail(workKey: String, fallbackAuthors: [String]) async throws -> AquaWorkDetail
    func subjectBooks(slug: String, limit: Int, offset: Int) async throws -> [AquaSubjectBook]
}
