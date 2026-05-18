import Foundation

struct AquaSearchHit: Identifiable, Hashable, Sendable {
    var id: String { openLibraryId }
    var openLibraryId: String
    var workKey: String?
    var title: String
    var authors: [String]
    var coverId: Int?
    var firstPublishYear: Int?
    var subjects: [String]
    var numberOfPagesMedian: Int?
}

struct AquaWorkDetail: Sendable {
    var workKey: String
    var title: String
    var authors: [String]
    var description: String?
    var subjects: [String]
    var firstPublishYear: Int?
    var coverId: Int?
    var numberOfPagesMedian: Int?
}

struct AquaSubjectBook: Identifiable, Hashable, Sendable {
    var id: String { key }
    var key: String
    var title: String
    var authors: [String]
    var coverId: Int?
    var firstPublishYear: Int?
}

struct AquaMoodDefinition: Identifiable, Hashable, Sendable {
    var id: String { moodKey }
    var moodKey: String
    var displayTitle: String
    var subjectSlugs: [String]
}
