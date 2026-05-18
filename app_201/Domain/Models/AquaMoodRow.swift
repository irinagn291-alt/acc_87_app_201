import Foundation

struct AquaSavedMoodBook: Identifiable, Hashable, Sendable {
    var id: UUID
    var openLibraryId: String
    var title: String
    var authors: [String]
    var coverId: Int?
}

struct AquaMoodListRow: Identifiable, Hashable, Sendable {
    var id: UUID
    var title: String
    var moodKey: String
    var createdAt: Date
    var books: [AquaSavedMoodBook]
}
