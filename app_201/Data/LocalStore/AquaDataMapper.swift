import Foundation

enum AquaDataMapper {
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    static func encodeStrings(_ value: [String]) -> String {
        (try? String(data: encoder.encode(value), encoding: .utf8)) ?? "[]"
    }

    static func decodeStrings(_ json: String) -> [String] {
        (try? decoder.decode([String].self, from: Data(json.utf8))) ?? []
    }

    static func toDomain(_ m: SDPilotBook) -> AquaBookEntry {
        AquaBookEntry(
            id: m.id,
            openLibraryId: m.openLibraryId,
            workKey: m.workKey,
            title: m.title,
            authors: decodeStrings(m.authorsJSON),
            coverId: m.coverId,
            coverURL: m.coverURL,
            firstPublishYear: m.firstPublishYear,
            subjects: decodeStrings(m.subjectsJSON),
            status: AquaReadStatus(rawValue: m.statusRaw) ?? .wantToRead,
            currentPage: m.currentPage,
            totalPages: m.totalPages,
            rating: m.rating,
            noteText: m.noteText,
            noteCreatedAt: m.noteCreatedAt,
            noteUpdatedAt: m.noteUpdatedAt,
            dateAdded: m.dateAdded,
            dateStarted: m.dateStarted,
            dateFinished: m.dateFinished,
            lastUpdated: m.lastUpdated
        )
    }

    static func apply(_ book: AquaBookEntry, to m: SDPilotBook) {
        m.openLibraryId = book.openLibraryId
        m.workKey = book.workKey
        m.title = book.title
        m.authorsJSON = encodeStrings(book.authors)
        m.coverId = book.coverId
        m.coverURL = book.coverURL
        m.firstPublishYear = book.firstPublishYear
        m.subjectsJSON = encodeStrings(book.subjects)
        m.statusRaw = book.status.rawValue
        m.currentPage = book.currentPage
        m.totalPages = book.totalPages
        m.rating = book.rating
        m.noteText = book.noteText
        m.noteCreatedAt = book.noteCreatedAt
        m.noteUpdatedAt = book.noteUpdatedAt
        m.dateAdded = book.dateAdded
        m.dateStarted = book.dateStarted
        m.dateFinished = book.dateFinished
        m.lastUpdated = book.lastUpdated
    }

    static func newModel(from book: AquaBookEntry) -> SDPilotBook {
        SDPilotBook(
            id: book.id,
            openLibraryId: book.openLibraryId,
            workKey: book.workKey,
            title: book.title,
            authorsJSON: encodeStrings(book.authors),
            coverId: book.coverId,
            coverURL: book.coverURL,
            firstPublishYear: book.firstPublishYear,
            subjectsJSON: encodeStrings(book.subjects),
            statusRaw: book.status.rawValue,
            currentPage: book.currentPage,
            totalPages: book.totalPages,
            rating: book.rating,
            noteText: book.noteText,
            noteCreatedAt: book.noteCreatedAt,
            noteUpdatedAt: book.noteUpdatedAt,
            dateAdded: book.dateAdded,
            dateStarted: book.dateStarted,
            dateFinished: book.dateFinished,
            lastUpdated: book.lastUpdated
        )
    }
}
