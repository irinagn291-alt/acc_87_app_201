import Foundation

struct AquaBookEntry: Identifiable, Hashable, Sendable {
    var id: UUID
    var openLibraryId: String
    var workKey: String?
    var title: String
    var authors: [String]
    var coverId: Int?
    var coverURL: String?
    var firstPublishYear: Int?
    var subjects: [String]
    var status: AquaReadStatus
    var currentPage: Int
    var totalPages: Int?
    var rating: Double?
    var noteText: String?
    var noteCreatedAt: Date?
    var noteUpdatedAt: Date?
    var dateAdded: Date
    var dateStarted: Date?
    var dateFinished: Date?
    var lastUpdated: Date
}
